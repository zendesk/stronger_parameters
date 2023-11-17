# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class DateConstraint < Constraint
    def value(v)
      return v if v.is_a?(Date)

      begin
        Date.parse v
      rescue ArgumentError, TypeError
        StrongerParameters::InvalidValue.new(v, "must be a date")
      end
    end
  end
end
