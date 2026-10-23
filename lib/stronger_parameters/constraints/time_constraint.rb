# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class TimeConstraint < Constraint
    def initialize(format: nil)
      unless [nil, :iso8601, :rfc3339].include?(format)
        raise ArgumentError, "Unsupported time format: #{format.inspect}"
      end

      @format = format
    end

    def value(v)
      return v if v.is_a?(Time)

      case @format
      when :iso8601
        Time.iso8601(v)
      when :rfc3339
        Time.rfc3339(v)
      else
        Time.parse(v)
      end
    rescue ArgumentError, TypeError
      message = @format ? "must be an #{@format} time" : "must be a time"
      StrongerParameters::InvalidValue.new(v, message)
    end
  end
end
