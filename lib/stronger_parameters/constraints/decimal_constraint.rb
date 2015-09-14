require 'stronger_parameters/constraints'

module StrongerParameters
  class DecimalConstraint < Constraint
    attr_reader :precision

    def initialize(precision)
      @precision = precision
    end

    def value(v)
      if precision > 0
        if v.is_a?(Float)
          return value(v.to_s)
        elsif v.is_a?(String) && v =~ /\A-?\d+\.?\d{#{precision}}\Z/
          return v.to_f
        end
      else
        integer = IntegerConstraint.new
        return integer.value(v)
      end

      StrongerParameters::InvalidValue.new(v, "must be a decimal with #{precision} precision")
    end
  end
end
