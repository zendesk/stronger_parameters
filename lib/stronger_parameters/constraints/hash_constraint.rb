require 'stronger_parameters/constraints'

module StrongerParameters
  class HashConstraint < Constraint
    attr_reader :constraints

    def initialize(constraints)
      @constraints = constraints.with_indifferent_access unless constraints.nil?
    end

    def value(v)
      if v.is_a?(Hash)
        return ActionController::Parameters.new(v).permit! if constraints.nil?
        return ActionController::Parameters.new(v).permit(constraints)
      end

      InvalidValue.new(v, "must be a hash")
    end

    def merge(other)
      other_constraints = other.is_a?(HashConstraint) ? other.constraints : other
      self.class.new(constraints.merge(other_constraints))
    end

    def ==(other)
      super && constraints == other.constraints
    end
  end
end
