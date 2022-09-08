# frozen_string_literal: true
require 'stronger_parameters/constraint'

module StrongerParameters
  class DateTimeConstraint < Constraint
    def value(v)
      return v if v.is_a?(DateTime)

      begin
        DateTime.parse v
      rescue ArgumentError, TypeError
        StrongerParameters::InvalidValue.new(v, "must be a datetime")
      end
    end
  end
end
