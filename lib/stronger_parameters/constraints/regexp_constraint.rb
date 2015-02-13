require 'stronger_parameters/constraints'

module StrongerParameters
  class RegexpConstraint < Constraint
    attr_reader :regexp

    def initialize(regexp)
      @regexp = regexp
      @string = StringConstraint.new
    end

    def value(v)
      v = @string.value(v)
      return v if v.is_a?(InvalidValue)
      if v =~ regexp
        v
      else
        InvalidValue.new(v, "must match #{regexp.source}")
      end
    end

    def ==(other)
      super && regexp == other.regexp
    end
  end
end
