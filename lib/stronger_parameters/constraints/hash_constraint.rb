# frozen_string_literal: true
require 'stronger_parameters/constraint'

module StrongerParameters
  class HashConstraint < Constraint
    attr_reader :constraints

    def initialize(constraints)
      @constraints = constraints.with_indifferent_access unless constraints.nil?
      super()
    end

    def value(v)
      return InvalidValue.new(v, "must be a hash") if !v.is_a?(Hash) && !v.is_a?(ActionController::Parameters)

      v = ActionController::Parameters.new(v) if v.is_a?(Hash)
      if constraints.nil?
        v.permit!
      else
        v.permit(constraints)
      end
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
