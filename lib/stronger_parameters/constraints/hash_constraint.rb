require 'stronger_parameters/constraints'

module StrongerParameters
  class HashConstraint < Constraint
    attr_reader :constraints

    def initialize(constraints)
      @constraints = constraints.with_indifferent_access
    end

    def value(v)
      if v.is_a?(Hash)
        return ActionController::Parameters.new(v).permit(constraints)
      end

      raise InvalidParameter.new(v, "must be a hash")
    end
  end
end
