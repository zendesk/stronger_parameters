require 'stronger_parameters/constraints'

module StrongerParameters
  class FixnumConstraint < Constraint
    def value(v)
      if v.is_a?(Fixnum)
        return v
      elsif v.is_a?(String) && v =~ /\A-?\d+\Z/
        return v.to_i
      end

      raise InvalidParameter.new(v, 'must be an integer')
    end
  end
end
