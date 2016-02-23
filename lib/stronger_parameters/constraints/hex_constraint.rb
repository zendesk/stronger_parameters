require 'stronger_parameters/constraints'

module StrongerParameters
  class HexConstraint < Constraint
    def value(v)
      return v if v =~ /\A[a-f0-9]+\z/i

      InvalidValue.new(v, 'must be a hexadecimal string')
    end
  end
end
