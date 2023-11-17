# frozen_string_literal: true
require "stronger_parameters/constraint"

module StrongerParameters
  class TimeIso8601Constraint < Constraint
    def value(v)
      Time.iso8601 v
    rescue ArgumentError, TypeError
      StrongerParameters::InvalidValue.new(v, "must be an iso8601 time")
    end
  end
end
