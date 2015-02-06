require 'stronger_parameters/constraints'

module StrongerParameters
  class ArrayConstraint < Constraint
    attr_reader :item_constraint

    def initialize(item_constraint)
      @item_constraint = item_constraint
    end

    def value(v)
      if v.is_a?(Array)
        return v.map do |item|
          result = item_constraint.value(item)
          return result if result.is_a?(InvalidParameter)
          result
        end
      end

      InvalidParameter.new(v, "must be an array")
    end

    def ==(other)
      super && item_constraint == other.item_constraint
    end
  end
end
