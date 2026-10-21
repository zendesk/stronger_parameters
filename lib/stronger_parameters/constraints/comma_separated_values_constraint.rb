# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class CommaSeparatedValuesConstraint < StrongerParameters::Constraint
    def initialize(item_constraint)
      @item_constraint = item_constraint
    end

    def value(input)
      return StrongerParameters::InvalidValue.new(input, "must be a string with comma separated values") unless input.is_a?(String)

      input.split(/,\s*/).map do |item|
        result = @item_constraint.value(item)
        return result if result.is_a?(StrongerParameters::InvalidValue)

        result
      end
    end
  end
end
