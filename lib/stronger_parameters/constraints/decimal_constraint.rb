require 'stronger_parameters/constraints'

module StrongerParameters
  class DecimalConstraint < Constraint
    attr_reader :precision, :scale

    def initialize(precision, scale)
      @precision = precision
      @scale = scale
    end

    def value(v)
      if scale > 0
        if v.is_a?(Float)
          return value(v.to_s)
        elsif v.is_a?(String) && v =~ /\A-?\d+\.?\d{#{scale}}\Z/
          return v.to_d
        end
      else
        integer = IntegerConstraint.new
        return integer.value(v)
      end

      StrongerParameters::InvalidValue.new(v, 'invalid decimal')
    end
  end
end
