require 'stronger_parameters/constraints'

module StrongerParameters
  class DecimalConstraint < Constraint
    attr_reader :precision, :scale

    def initialize(precision, scale)
      @precision = precision
      @scale = scale
    end

    def value(v)
      if (v.is_a?(Fixnum) || v.is_a?(Bignum)) && (v.abs.to_s.size <= precision)
        return v.to_d
      elsif v.is_a?(Float) && (v.abs.to_s.size - 1) <= precision
        return value(v.to_s)
      elsif v.is_a?(String)
        if scale > 0 && v =~ /\A-?(\d{1,#{precision - scale}}\.\d{1,#{scale}}|\d{1,#{precision}})\Z/
          return v.to_d
        elsif v =~ /\A-?\d{1,#{precision - scale}}\Z/
          return v.to_d
        end

      end

      StrongerParameters::InvalidValue.new(v, 'must be a decimal')
    end
  end
end
