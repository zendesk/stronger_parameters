require 'stronger_parameters/errors'

module StrongerParameters
  class Constraint
    def value(v)
      v
    end

    def |(other)
      OrConstraint.new(self, other)
    end

    def &(other)
      AndConstraint.new(self, other)
    end

    def ==(other)
      self.class == other.class
    end
  end

  class OrConstraint < Constraint
    attr_reader :constraints

    def initialize(*constraints)
      @constraints = constraints
    end

    def value(v)
      exception = nil

      constraints.each do |c|
        result = c.value(v)
        if result.is_a?(InvalidValue)
          exception ||= result
        else
          return result
        end
      end

      exception
    end

    def |(other)
      constraints << other
      self
    end

    def ==(other)
      super && constraints == other.constraints
    end
  end

  class AndConstraint < Constraint
    attr_reader :constraints

    def initialize(*constraints)
      @constraints = constraints
    end

    def value(v)
      constraints.each do |c|
        v = c.value(v)
        return v if v.is_a?(InvalidValue)
      end
      v
    end

    def &(other)
      constraints << other
      self
    end

    def ==(other)
      super && constraints == other.constraints
    end
  end
end
