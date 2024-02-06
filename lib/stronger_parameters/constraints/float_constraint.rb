# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class FloatConstraint < Constraint
    def value(v)
      if v.is_a?(Float)
        return v
      elsif v.is_a?(String) && v =~ /\A-?\d+\.\d+\Z/
        return v.to_f
      end

      StrongerParameters::InvalidValue.new(v, "must be a float")
    end
  end
end
