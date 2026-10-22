# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class DateTimeConstraint < Constraint
    def initialize(format: nil, use_zone: false)
      unless [nil, :iso8601, :rfc3339].include?(format)
        raise ArgumentError, "Unsupported datetime format: #{format.inspect}"
      end

      @format = format
      @use_zone = use_zone
    end

    def value(v)
      return v if @format.nil? && v.is_a?(DateTime)

      parser = (@use_zone && Time.zone) || DateTime
      parser.public_send(@format || :parse, v) || invalid_value(v)
    rescue ArgumentError, TypeError
      invalid_value(v)
    end

    private

    def invalid_value(v)
      message = @format ? "must be an #{@format} datetime" : "must be a datetime"
      StrongerParameters::InvalidValue.new(v, message)
    end
  end
end
