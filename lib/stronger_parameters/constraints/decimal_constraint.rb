# frozen_string_literal: true
require 'stronger_parameters/constraint'

module StrongerParameters
  class DecimalConstraint < Constraint
    def initialize(precision, scale)
      @precision = precision
      @scale = scale
      @regex = /\A-?\d{1,#{precision - scale}}#{"(\\.\\d{1,#{scale}})?" if scale > 0}\Z/
      super()
    end

    def value(v)
      match = v.to_s
      if match =~ @regex
        BigDecimal(match)
      else
        StrongerParameters::InvalidValue.new(v, "must be a decimal with precision #{@precision} and scale #{@scale}")
      end
    end
  end
end
