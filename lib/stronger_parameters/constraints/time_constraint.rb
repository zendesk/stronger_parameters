# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class TimeConstraint < Constraint
    def initialize(format: nil, use_zone: false)
      unless [nil, :iso8601, :rfc3339].include?(format)
        raise ArgumentError, "Unsupported time format: #{format.inspect}"
      end

      @format = format
      @use_zone = use_zone
    end

    def value(v)
      return v if @format.nil? && v.is_a?(Time)

      parser = (@use_zone && Time.zone) || Time
      parser.public_send(@format || :parse, v) || invalid_value(v)
    rescue ArgumentError, TypeError
      invalid_value(v)
    end

    private

    def invalid_value(v)
      message = @format ? "must be an #{@format} time" : "must be a time"
      StrongerParameters::InvalidValue.new(v, message)
    end
  end
end
