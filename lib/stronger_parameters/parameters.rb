# frozen_string_literal: true

require "action_pack"

require "action_controller/base"
require "action_controller/api"
require "action_controller/metal/strong_parameters"

require "stronger_parameters/constraints"
require "stronger_parameters/errors"

module StrongerParameters
  module Parameters
    extend ActiveSupport::Concern

    ABSENT = BasicObject.new

    included do
      alias_method :hash_filter_without_stronger_parameters, :hash_filter
      alias_method :hash_filter, :hash_filter_with_stronger_parameters
      cattr_accessor :action_on_invalid_parameters, instance_accessor: false
      cattr_accessor :allow_nil_for_everything, instance_accessor: false
    end

    module ClassMethods
      def anything
        Constraint.new
      end

      def present
        PresentConstraint.new
      end

      def nil
        NilConstraint.new
      end

      def string(options = {})
        StringConstraint.new(options)
      end

      def regexp(regex)
        RegexpConstraint.new(regex)
      end

      def integer
        @integer ||= IntegerConstraint.new
      end

      def lt(limit)
        LessThanConstraint.new(limit)
      end

      def lte(limit)
        LessThanOrEqualConstraint.new(limit)
      end

      def gt(limit)
        GreaterThanConstraint.new(limit)
      end

      def gte(limit)
        GreaterThanOrEqualConstraint.new(limit)
      end

      def integer32
        integer & lt(2**31) & gte(-2**31)
      end

      def integer64
        integer & lt(2**63) & gte(-2**63)
      end

      def id
        integer & lt(2**31) & gte(0)
      end

      def uid
        integer & lt(2**32) & gte(0)
      end

      def bigid
        integer & lt(2**63) & gte(0)
      end

      def ubigid
        integer & lt(2**64) & gte(0)
      end

      def enumeration(*allowed)
        EnumerationConstraint.new(*allowed)
      end
      alias_method :enum, :enumeration

      def boolean
        BooleanConstraint.new
      end

      def float
        FloatConstraint.new
      end

      def array(item_constraint)
        ArrayConstraint.new(item_constraint)
      end

      def size(range)
        SizeConstraint.new(range)
      end

      def csv(item_constraint)
        CommaSeparatedValuesConstraint.new(item_constraint)
      end

      def map(constraints = nil)
        HashConstraint.new(constraints)
      end

      def nil_string
        NilStringConstraint.new
      end

      def date(format: nil)
        DateConstraint.new(format:)
      end

      def date_iso8601
        date(format: :iso8601)
      end

      def time(format: nil)
        TimeConstraint.new(format:)
      end

      def time_iso8601
        time(format: :iso8601)
      end

      def datetime(format: nil)
        DateTimeConstraint.new(format:)
      end

      def datetime_iso8601
        datetime(format: :iso8601)
      end

      def file
        FileConstraint.new
      end

      def decimal(precision = 8, scale = 2)
        DecimalConstraint.new(precision, scale)
      end

      def hex
        HexConstraint.new
      end

      def ulid
        UlidConstraint.new
      end
    end

    def hash_filter_with_stronger_parameters(params, filter, **kwargs)
      stronger_filter = ActiveSupport::HashWithIndifferentAccess.new
      other_filter = ActiveSupport::HashWithIndifferentAccess.new

      filter.each do |k, v|
        if v.is_a?(Constraint)
          stronger_filter[k] = v
        else
          other_filter[k] = v
        end
      end

      hash_filter_without_stronger_parameters(params, other_filter, **kwargs)

      stronger_filter.each do |key, constraint|
        value = fetch(key, ABSENT)

        result = if value.equal?(ABSENT)
          next if self.class.allow_nil_for_everything || !constraint.required?
          InvalidValue.new(value = nil, "must be present")
        else
          if value.nil? && self.class.allow_nil_for_everything
            params[key] = nil
            next
          end
          constraint.value(value)
        end

        if result.is_a?(InvalidValue)
          name = "invalid_parameter.action_controller"
          ActiveSupport::Notifications.instrument(name, key: key, value: value, message: result.message)

          action = self.class.action_on_invalid_parameters
          case action
          when :raise, nil
            raise StrongerParameters::InvalidParameter.new(result, key)
          when Proc
            action.call(result, key)
          when :log
            Rails.logger.warn("#{key} #{result.message}, but was: #{value.inspect}")
          else
            raise ArgumentError, "Unsupported value in action_on_invalid_parameters: #{action}"
          end

          result = value
        end

        params[key] = result
        # Rails marks only the parent permitted; custom nested results need their own permissions.
        permit_constraint_value(params[key])
      end
    end

    private

    def permit_constraint_value(value)
      case value
      when ActionController::Parameters
        value.permit! unless value.permitted?
      when Array
        value.each { |item| permit_constraint_value(item) }
      end
    end
  end

  module ControllerSupport
    extend ActiveSupport::Concern

    Parameters = ActionController::Parameters

    included do
      # TODO: this is not consistent with the behavior of raising ActionController::UnpermittedParameters
      # should have the same render vs raise behavior in test/dev ... see permitted_parameters_test.rb
      rescue_from(StrongerParameters::InvalidParameter) do |e|
        if request.format.to_s.include?("json")
          render json: {error: e.message}, status: :bad_request
        else
          render plain: e.message, status: :bad_request
        end
      end
    end
  end
end

ActionController::Parameters.include StrongerParameters::Parameters
ActionController::Base.include StrongerParameters::ControllerSupport
ActionController::API.include StrongerParameters::ControllerSupport
