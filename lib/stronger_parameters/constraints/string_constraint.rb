# frozen_string_literal: true
require 'stronger_parameters/constraint'

module StrongerParameters
  class StringConstraint < Constraint
    attr_reader :maximum_length, :minimum_length

    def initialize(options = {})
      @maximum_length = options[:maximum_length] || options[:max_length]
      @minimum_length = options[:minimum_length] || options[:min_length]
    end

    def value(v)
      if v.is_a?(String)
        if maximum_length && v.bytesize > maximum_length
          return InvalidValue.new(v, "can not be longer than #{maximum_length} bytes")
        elsif minimum_length && v.bytesize < minimum_length
          return InvalidValue.new(v, "can not be shorter than #{minimum_length} bytes")
        elsif !v.valid_encoding?
          return InvalidValue.new(v, 'must have valid encoding')
        end

        return v
      end

      InvalidValue.new(v, 'must be a string')
    end
  end
end
