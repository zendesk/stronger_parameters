# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class DateConstraint < Constraint
    def initialize(format: nil)
      unless [nil, :iso8601, :rfc3339].include?(format)
        raise ArgumentError, "Unsupported date format: #{format.inspect}"
      end

      @format = format
    end

    def value(v)
      return v if v.is_a?(Date)

      case @format
      when :iso8601
        Date.iso8601(v)
      when :rfc3339
        Date.rfc3339(v)
      else
        Date.parse(v)
      end
    rescue ArgumentError, TypeError
      message = @format ? "must be an #{@format} date" : "must be a date"
      StrongerParameters::InvalidValue.new(v, message)
    end
  end
end
