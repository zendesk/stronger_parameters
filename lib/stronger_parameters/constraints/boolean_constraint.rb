require 'stronger_parameters/constraints'

module StrongerParameters
  class BooleanConstraint < Constraint
    TRUE_VALUES  = [true, 'true', '1', 1].freeze
    FALSE_VALUES = [false, 'false', '0', 0].freeze

    def value(v)
      if TRUE_VALUES.include?(v)
        return true
      end

      if FALSE_VALUES.include?(v)
        return false
      end

      raise InvalidParameter.new(v, "must be either true or false")
    end
  end
end
