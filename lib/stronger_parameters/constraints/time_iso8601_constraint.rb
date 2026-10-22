# frozen_string_literal: true

require "stronger_parameters/constraints/time_constraint"

module StrongerParameters
  class TimeIso8601Constraint < TimeConstraint
    def initialize(use_zone: false)
      super(format: :iso8601, use_zone:)
    end
  end
end
