module StrongerParameters
  class InvalidParameter < StandardError
    attr_accessor :key, :value

    def initialize(value, message)
      @value = value
      super(message)
    end

    def to_s
      if key.present?
        "found invalid value for #{key}. Value #{super}"
      else
        "found invalid value. Value #{super}"
      end
    end
  end

  class Constraint
    def value(v)
      raise InvalidParameter.new(v, "#{self.class.name} should never be used directly")
    end

    def |(other)
      OrConstraint.new(self, other)
    end

    def &(other)
      AndConstraint.new(self, other)
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
        begin
          return c.value(v)
        rescue InvalidParameter => e
          exception ||= e
        end
      end

      raise exception
    end

    def |(other)
      constraints << other
      self
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
      end
      v
    end

    def &(other)
      constraints << other
      self
    end
  end
end

require 'stronger_parameters/constraints/string_constraint'
require 'stronger_parameters/constraints/fixnum_constraint'
require 'stronger_parameters/constraints/boolean_constraint'
require 'stronger_parameters/constraints/array_constraint'
require 'stronger_parameters/constraints/hash_constraint'
require 'stronger_parameters/constraints/enumeration_constraint'
require 'stronger_parameters/constraints/comparison_constraints'
