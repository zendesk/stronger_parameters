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

require 'stronger_parameters/constraints/string_constraint'
require 'stronger_parameters/constraints/float_constraint'
require 'stronger_parameters/constraints/date_time_constraint'
require 'stronger_parameters/constraints/regexp_constraint'
require 'stronger_parameters/constraints/integer_constraint'
require 'stronger_parameters/constraints/nil_constraint'
require 'stronger_parameters/constraints/boolean_constraint'
require 'stronger_parameters/constraints/array_constraint'
require 'stronger_parameters/constraints/hash_constraint'
require 'stronger_parameters/constraints/enumeration_constraint'
require 'stronger_parameters/constraints/comparison_constraints'
require 'stronger_parameters/constraints/nil_string_contraint'
