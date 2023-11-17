# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class NilConstraint < Constraint
    def value(v)
      return v if v.nil?

      InvalidValue.new(v, "must be an nil")
    end
  end
end
