require 'stronger_parameters/constraint'

module StrongerParameters
  class IntegerConstraint < Constraint
    def value(v)
      if v.is_a?(Integer)
        return v
      elsif v.is_a?(String) && v =~ /\A-?\d+\Z/
        return v.to_i
      end

      InvalidValue.new(v, 'must be an integer')
    end
  end
end
