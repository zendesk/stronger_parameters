# frozen_string_literal: true
require 'stronger_parameters/constraint'

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
      elsif ActionPack::VERSION::MAJOR >= 5 && v.is_a?(ActionController::Parameters)
        return v.permit! if constraints.nil?
        return v.permit(constraints)
      end

      InvalidValue.new(v, "must be a hash")
    end

    def merge(other)
      other_constraints = other.is_a?(HashConstraint) ? other.constraints : other
      self.class.new(constraints.merge(other_constraints))
    end
  end
end
