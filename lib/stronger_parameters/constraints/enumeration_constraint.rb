require 'stronger_parameters/constraints'

module StrongerParameters
  class EnumerationConstraint < Constraint
    attr_reader :allowed

    def initialize(*allowed)
      @allowed = allowed
    end

    def value(v)
      return v if allowed.include?(v)

      raise InvalidParameter.new(v, "must be one of these: #{allowed.to_sentence}")
    end

    def ==(other)
      super && allowed == other.allowed
    end
  end
end
