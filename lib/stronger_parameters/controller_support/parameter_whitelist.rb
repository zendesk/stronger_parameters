require 'stronger_parameters/constraints'

module StrongerParameters
  module ControllerSupport
    module ParameterWhitelist
      def self.included(klass)
        klass.extend ClassMethods
        klass.before_action :whitelist_parameters
      end

      class AllowedParameters < HashWithIndifferentAccess
        def initialize(other = nil)
          super()
          merge!(other) unless other.nil?
        end

        def merge!(other)
          return self if other.nil?

          other.each do |key, value|
            value = sugar(value)

            if value.is_a?(StrongerParameters::Constraint)
              self[key] = value
            else
              self[key] ||= self.class.new
              self[key].merge!(value)
            end
          end

          self
        end

        def merge(other)
          dup.merge!(other)
        end

        def dup
          super.tap do |duplicate|
            duplicate.each do |k, v|
              duplicate[k] = if v == true
                true
              else
                v.dup
              end
            end
          end
        end

        def sugar(value)
          case value
          when Array
            ActionController::Parameters.array(*value.map { |v| sugar(v) }) | ActionController::Parameters.nil
          when Hash
            constraints = value.each_with_object({}) do |(key, v), memo|
              memo[key] = sugar(v)
            end
            ActionController::Parameters.map(constraints)
          else
            value
          end
        end
      end

      DEFAULT_ALLOWED = AllowedParameters.new(
        controller: ActionController::Parameters.anything,
        action: ActionController::Parameters.anything,
        format: ActionController::Parameters.anything,
        authenticity_token: ActionController::Parameters.string
      )

      module ClassMethods
        def self.extended(base)
          base.class_eval do
            class_attribute :log_stronger_parameter_violations, instance_accessor: false
          end
        end

        def log_stronger_parameter_violations!
          self.log_stronger_parameter_violations = true
        end

        def allow_parameters(action, allowed)
          if allowed_parameters[action] == :anything && allowed != :anything
            raise ArgumentError, "#{self}/#{action} can not add to :anything"
          end

          allowed_parameters.deep_merge!(action => allowed)
        end

        def allowed_parameters
          @allowed_parameters ||= if superclass.respond_to?(:allowed_parameters)
            superclass.allowed_parameters.deep_dup
          else
            all = DEFAULT_ALLOWED.dup
            all[:test_route] = ActionController::Parameters.string if Rails.env.test?
            { all: all }.with_indifferent_access
          end
        end

        def allowed_parameters_for(action)
          unless for_action = allowed_parameters[action]
            location = instance_method(action).source_location
            raise KeyError, "Action #{action} for #{self} does not have any allowed parameters (#{location.join(":")})"
          end
          return :anything if for_action == :anything
          allowed_parameters[:all].merge(for_action)
        end
      end

      private

      def whitelist_parameters
        action = params[:action].to_sym
        allowed = self.class.allowed_parameters_for(action)

        if allowed == :anything
          Rails.logger.warn("#{params[:controller]}/#{params[:action]} does not filter parameters")
          return
        end

        permitted_params = without_invalid_parameter_exceptions { params.permit(allowed) }
        restricted_keys = flat_keys(params) - flat_keys(permitted_params)
        filter_params = !self.class.log_stronger_parameter_violations

        show_restricted_keys(restricted_keys, filter_params)

        return unless filter_params

        params.replace(permitted_params)
        params.permit!
        request.params.replace(permitted_params)

        logged_params = request.send(:parameter_filter).filter(permitted_params) # Removing passwords, etc
        Rails.logger.info("  Filtered Parameters: #{logged_params.inspect}")
      end

      def show_restricted_keys(restricted_keys, filter_params)
        return if restricted_keys.empty?

        log_prefix = (filter_params ? 'Removed' : 'Found')
        message = "#{log_prefix} restricted keys #{restricted_keys.inspect} from parameters according to whitelist"

        header = Rails.configuration.try(:stronger_parameters_violation_header) # might be undefined
        response.headers[header] = message if response && header

        Rails.logger.info("  #{message}")
      end

      def without_invalid_parameter_exceptions
        if self.class.log_stronger_parameter_violations
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
        hash.flat_map { |k, v| v.is_a?(Hash) ? flat_keys(v).map { |x| "#{k}.#{x}" }.push(k) : k }
      end
    end
  end
end
