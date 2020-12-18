# frozen_string_literal: true
require 'stronger_parameters/constraint'

module StrongerParameters
  class EnumerationConstraint < Constraint
    attr_reader :allowed

    def initialize(*allowed)
      @allowed = allowed
      super()
    end

    def value(v)
      return v if allowed.include?(v)

      InvalidValue.new(v, "must be one of these: #{allowed.to_sentence}")
    end

    def ==(other)
      super && allowed == other.allowed
    end
  end
end
