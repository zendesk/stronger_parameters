# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class DateTimeConstraint < Constraint
    def initialize(format: nil)
      unless [nil, :iso8601, :rfc3339].include?(format)
        raise ArgumentError, "Unsupported datetime format: #{format.inspect}"
      end

      @format = format
    end

    def value(v)
      return v if v.is_a?(DateTime)

      case @format
      when :iso8601
        DateTime.iso8601(v)
      when :rfc3339
        DateTime.rfc3339(v)
      else
        DateTime.parse(v)
      end
    rescue ArgumentError, TypeError
      message = @format ? "must be an #{@format} datetime" : "must be a datetime"
      StrongerParameters::InvalidValue.new(v, message)
    end
  end
end
