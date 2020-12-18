# frozen_string_literal: true
require 'stronger_parameters/constraint'

module StrongerParameters
  class ArrayConstraint < Constraint
    attr_reader :item_constraint

    def initialize(item_constraint)
      @item_constraint = item_constraint
      super()
    end

    def value(v)
      if v.is_a?(Array)
        return v.map do |item|
          result = item_constraint.value(item)
          return result if result.is_a?(InvalidValue)

          result
        end
      end

      InvalidValue.new(v, "must be an array")
    end

    def ==(other)
      super && item_constraint == other.item_constraint
    end
  end
end
