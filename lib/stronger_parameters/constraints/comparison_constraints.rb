require 'stronger_parameters/constraints'

module StrongerParameters
  class LessThanConstraint < Constraint
    attr_reader :limit

    def initialize(limit)
      @limit = limit
    end

    def value(v)
      return v if v < limit

      raise InvalidParameter.new(v, "must be less than #{limit}")
    end
  end

  class LessThanOrEqualConstraint < Constraint
    attr_reader :limit

    def initialize(limit)
      @limit = limit
    end

    def value(v)
      return v if v <= limit

      raise InvalidParameter.new(v, "must be less than or equal to #{limit}")
    end
  end

  class GreaterThanConstraint < Constraint
    attr_reader :limit

    def initialize(limit)
      @limit = limit
    end

    def value(v)
      return v if v > limit

      raise InvalidParameter.new(v, "must be greater than #{limit}")
    end
  end

  class GreaterThanOrEqualConstraint < Constraint
    attr_reader :limit

    def initialize(limit)
      @limit = limit
    end

    def value(v)
      return v if v >= limit

      raise InvalidParameter.new(v, "must be greater than or equal to #{limit}")
    end
  end
end
