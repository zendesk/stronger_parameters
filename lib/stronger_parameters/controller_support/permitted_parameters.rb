# frozen_string_literal: true
require 'stronger_parameters/constraints'

module StrongerParameters
  module ControllerSupport
    module PermittedParameters
      def self.included(klass)
        klass.extend ClassMethods
        klass.public_send :before_action, :permit_parameters
      end

      def self.sugar(value)
        case value
        when Array
          ActionController::Parameters.array(*value.map { |v| sugar(v) })
        when Hash
          constraints = value.transform_values do |v|
            sugar(v)
          end
          ActionController::Parameters.map(constraints)
        else
          value
        end
      end

      DEFAULT_PERMITTED = {
        controller: ActionController::Parameters.anything,
        action: ActionController::Parameters.anything,
        format: ActionController::Parameters.anything,
        authenticity_token: ActionController::Parameters.string,
        utf8: Parameters.string,
        _method: Parameters.string,
        commit: Parameters.string
      }.freeze

      module ClassMethods
        def self.extended(base)
          base.send :class_attribute, :log_unpermitted_parameters, instance_accessor: false
        end

        def log_invalid_parameters!
          self.log_unpermitted_parameters = true
        end

        def permitted_parameters(action, permitted)
          if permit_parameters[action] == :skip || permitted == :skip
            permit_parameters[action] = permitted
          else
            action_permitted = (permit_parameters[action] ||= {})
            action_permitted.deep_merge!(permitted)
          end
        end

        def permitted_parameters_for(action)
          unless for_action = permit_parameters[action]
            # NOTE: there is no easy way to test this, so make sure to test with
            # a real rails controller if you make changes.
            message = "Action #{action} for #{self} does not have any permitted parameters"
            message += " (#{instance_method(action).source_location.join(":")})" if method_defined?(action)
            raise(KeyError, message)
          end
          return :skip if for_action == :skip

          # FYI: we should be able to call sugar on the result of deep_merge, but it breaks tests
          permit_parameters[:all].deep_merge(for_action).
            transform_values { |v| PermittedParameters.sugar(v) }
        end

        private

        def permit_parameters
          @permit_parameters ||= if superclass.respond_to?(:permit_parameters, true)
            superclass.send(:permit_parameters).deep_dup
          else
            {all: DEFAULT_PERMITTED.deep_dup}
          end
        end
      end

      private

      def permit_parameters
        action = params.fetch(:action).to_sym
        permitted = self.class.permitted_parameters_for(action)
        return if permitted == :skip

        # TODO: invalid values should also be logged, but atm only invalid keys are
        log_unpermitted = self.class.log_unpermitted_parameters
        permitted_params = without_invalid_parameter_exceptions(log_unpermitted) { params.permit(permitted) }
        unpermitted_keys = flat_keys(params) - flat_keys(permitted_params)

        show_unpermitted_keys(unpermitted_keys, log_unpermitted)

        return if log_unpermitted

        params.send(:parameters).replace(permitted_params)
        params.permit!

        request.params.replace(permitted_params)

        logged_params = request.send(:parameter_filter).filter(permitted_params) # Removing passwords, etc
        Rails.logger.info("  Filtered Parameters: #{logged_params.inspect}")
      end

      def show_unpermitted_keys(unpermitted_keys, log_unpermitted)
        return if unpermitted_keys.empty?

        log_prefix = (log_unpermitted ? 'Found' : 'Removed')
        message =
          "#{log_prefix} restricted keys #{unpermitted_keys.inspect} from parameters according to permitted list"

        if Rails.configuration.respond_to?(:stronger_parameters_violation_header)
          header = Rails.configuration.stronger_parameters_violation_header
        end
        response.headers[header] = message if response && header

        Rails.logger.info("  #{message}")
      end

      def without_invalid_parameter_exceptions(log)
        if log
          begin
            old = ActionController::Parameters.action_on_invalid_parameters
            ActionController::Parameters.action_on_invalid_parameters = :log
            yield
          ensure
            ActionController::Parameters.action_on_invalid_parameters = old
          end
        else
          yield
        end
      end

      def flat_keys(hash)
        hash = hash.send(:parameters) if hash.is_a?(ActionController::Parameters)
        hash.flat_map { |k, v| v.is_a?(Hash) ? flat_keys(v).map { |x| "#{k}.#{x}" }.push(k) : k }
      end
    end
  end
end
