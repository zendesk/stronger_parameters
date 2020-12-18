# frozen_string_literal: true
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

    def required
      RequiredConstraint.new(self)
    end

    def required?
      false
    end
  end

  class OrConstraint < Constraint
    attr_reader :constraints

    def initialize(*constraints)
      @constraints = constraints
      super()
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

    def required?
      constraints.all?(&:required?)
    end
  end

  class AndConstraint < Constraint
    attr_reader :constraints

    def initialize(*constraints)
      @constraints = constraints
      super()
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

    def required?
      constraints.any?(&:required?)
    end
  end

  class RequiredConstraint < Constraint
    def initialize(other)
      @other = other
      super()
    end

    def value(v)
      @other.value(v)
    end

    def required?
      true
    end
  end
end
