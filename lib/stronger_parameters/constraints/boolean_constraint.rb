# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class BooleanConstraint < Constraint
    TRUE_VALUES = [true, "true", "1", 1, "on"].freeze
    FALSE_VALUES = [false, "false", "0", 0].freeze

    def value(v)
      v = v.downcase if v.is_a?(String)

      return true if TRUE_VALUES.include?(v)

      return false if FALSE_VALUES.include?(v)

      InvalidValue.new(v, "must be either true or false")
    end
  end
end
