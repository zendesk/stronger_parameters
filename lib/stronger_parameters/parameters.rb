require 'action_pack'

if ActionPack::VERSION::MAJOR == 3
  require 'action_controller/parameters'
else
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
    end

    module ClassMethods
      def anything
        Constraint.new
      end

      def string(options = {})
        StringConstraint.new(options)
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
        integer & lte(2 ** 31) & gte(-2 ** 31)
      end

      def integer64
        integer & lte(2 ** 63) & gte(-2 ** 63)
      end

      def id
        integer & gte(0)
      end

      def smallid
        integer & lt(2 ** 32) & gte(0)
      end

      def enumeration(*allowed)
        EnumerationConstraint.new(*allowed)
      end
      alias_method :enum, :enumeration

      def boolean
        BooleanConstraint.new
      end

      def array(item_constraint)
        ArrayConstraint.new(item_constraint)
      end

      def map(constraints = nil)
        HashConstraint.new(constraints)
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
        if value.nil?
          params[key] = nil
          next
        end

        constraint = stronger_filter[key]
        begin
          params[key] = constraint.value(value)
        rescue InvalidParameter => e
          e.key = key

          name = "invalid_parameter.action_controller"
          ActiveSupport::Notifications.publish(name, :key => key, :value => value, :message => e.message)

          params[key] = value

          raise if self.class.action_on_invalid_parameters == :raise
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
