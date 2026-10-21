# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "stronger_parameters/constraint"

module StrongerParameters
  class PresentConstraint < Constraint
    def value(v)
      return v if v.present?

      InvalidValue.new(v, "must not be empty")
    end
  end
end
