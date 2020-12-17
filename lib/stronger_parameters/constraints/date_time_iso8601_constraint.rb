# frozen_string_literal: true
require 'stronger_parameters/constraint'

module StrongerParameters
  class DateTimeIso8601Constraint < Constraint
    def value(v)
      DateTime.iso8601 v
    rescue ArgumentError, TypeError
      StrongerParameters::InvalidValue.new(v, "must be an iso8601 date")
    end
  end
end
