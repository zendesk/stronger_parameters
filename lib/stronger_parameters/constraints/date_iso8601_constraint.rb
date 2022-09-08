# frozen_string_literal: true
require 'stronger_parameters/constraint'

module StrongerParameters
  class DateIso8601Constraint < Constraint
    def value(v)
      Date.iso8601 v
    rescue ArgumentError, TypeError
      StrongerParameters::InvalidValue.new(v, "must be an iso8601 date")
    end
  end
end
