require 'stronger_parameters/constraints'

module StrongerParameters
  class ComparisonConstraints < Constraint
    attr_reader :limit

    def initialize(limit)
      @limit = limit
    end

    def ==(other)
      super && limit == other.limit
    end
  end

  class LessThanConstraint < ComparisonConstraints
    def value(v)
      return v if v < limit

      InvalidParameter.new(v, "must be less than #{limit}")
    end
  end

  class LessThanOrEqualConstraint < ComparisonConstraints
    def value(v)
      return v if v <= limit

      InvalidParameter.new(v, "must be less than or equal to #{limit}")
    end
  end

  class GreaterThanConstraint < ComparisonConstraints
    def value(v)
      return v if v > limit

      InvalidParameter.new(v, "must be greater than #{limit}")
    end
  end

  class GreaterThanOrEqualConstraint < ComparisonConstraints
    def value(v)
      return v if v >= limit

      InvalidParameter.new(v, "must be greater than or equal to #{limit}")
    end
  end
end
