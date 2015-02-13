require 'stronger_parameters/constraints'

module StrongerParameters
  class NilConstraint < Constraint
    def value(v)
      return v if v.nil?

      InvalidValue.new(v, 'must be an nil')
    end
  end
end
