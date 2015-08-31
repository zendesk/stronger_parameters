require 'action_pack'

if ActionPack::VERSION::MAJOR == 3
  require 'action_controller/parameters'
else
  require 'action_controller/base'
  require 'action_controller/metal/strong_parameters'
end

require 'stronger_parameters/constraints'
require 'stronger_parameters/errors'

module StrongerParameters
  module Parameters
    extend ActiveSupport::Concern

    included do
      alias_method_chain :hash_filter, :stronger_parameters
      cattr_accessor :action_on_invalid_parameters, :instance_accessor => false
      cattr_accessor :allow_nil_for_everything, :instance_accessor => false
    end

    module ClassMethods
      def anything
        Constraint.new
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
        integer & lt(2 ** 31) & gte(-2 ** 31)
      end

      def integer64
        integer & lt(2 ** 63) & gte(-2 ** 63)
      end

      def id
        integer & lt(2 ** 31) & gte(0)
      end

      def uid
        integer & lt(2 ** 32) & gte(0)
      end

      def bigid
        integer & lt(2 ** 63) & gte(0)
      end

      def ubigid
        integer & lt(2 ** 64) & gte(0)
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

      def map(constraints = nil)
        HashConstraint.new(constraints)
      end

      def nil_string
        NilStringConstraint.new
      end

      def datetime
        DateTimeConstraint.new
      end
    end

    def hash_filter_with_stronger_parameters(params, filter)
      stronger_filter = ActiveSupport::HashWithIndifferentAccess.new
      other_filter    = ActiveSupport::HashWithIndifferentAccess.new

      filter.each do |k,v|
        if v.is_a?(Constraint)
          stronger_filter[k] = v
        else
          other_filter[k] = v
        end
      end

      hash_filter_without_stronger_parameters(params, other_filter)

      slice(*stronger_filter.keys).each do |key, value|
        if value.nil? && self.class.allow_nil_for_everything
          params[key] = nil
          next
        end

        constraint = stronger_filter[key]
        result = constraint.value(value)
        if result.is_a?(InvalidValue)
          name = "invalid_parameter.action_controller"
          ActiveSupport::Notifications.publish(name, :key => key, :value => value, :message => result.message)

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

          params[key] = value
        else
          params[key] = result
        end
      end
    end
  end

  module ControllerSupport
    extend ActiveSupport::Concern

    Parameters = ActionController::Parameters

    included do
      rescue_from(StrongerParameters::InvalidParameter) do |e|
        render :text => "Invalid parameter: #{e.key} #{e.message}", :status => :bad_request
      end
    end
  end
end

ActionController::Parameters.send :include, StrongerParameters::Parameters
ActionController::Base.send :include, StrongerParameters::ControllerSupport
