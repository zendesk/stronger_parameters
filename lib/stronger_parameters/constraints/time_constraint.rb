# frozen_string_literal: true
require "stronger_parameters/constraint"

module StrongerParameters
  class TimeConstraint < Constraint
    def value(v)
      return v if v.is_a?(Time)

      begin
        Time.parse v
      rescue ArgumentError, TypeError
        StrongerParameters::InvalidValue.new(v, "must be a time")
      end
    end
  end
end
