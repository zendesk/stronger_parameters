# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class SizeConstraint < StrongerParameters::Constraint
    def initialize(range)
      @range = range
    end

    def value(input)
      return StrongerParameters::InvalidValue.new(input, "must be an array") unless input.is_a?(Array)

      return input if @range.cover?(input.size)

      if @range.begin && @range.end
        if @range.begin == @range.end
          StrongerParameters::InvalidValue.new(input, "must have exactly #{@range.begin} #{"element".pluralize(@range.begin)}")
        else
          StrongerParameters::InvalidValue.new(input, "must have between #{@range.begin} and #{@range.end} elements")
        end
      elsif @range.begin
        StrongerParameters::InvalidValue.new(input, "must have at least #{@range.begin} #{"element".pluralize(@range.begin)}")
      else
        StrongerParameters::InvalidValue.new(input, "must have at most #{@range.end} #{"element".pluralize(@range.end)}")
      end
    end
  end
end
