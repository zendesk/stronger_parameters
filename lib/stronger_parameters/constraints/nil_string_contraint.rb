require 'stronger_parameters/constraints'

module StrongerParameters
  class NilStringConstraint < Constraint
    NULL_VALUES = [nil, '', 'undefined']

    def value(v)
      if NULL_VALUES.include?(v)
        nil
      else
        StrongerParameters::InvalidValue.new(v, "must be a nil string")
      end
    end
  end
end
