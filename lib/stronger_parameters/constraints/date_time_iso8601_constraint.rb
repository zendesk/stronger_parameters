# frozen_string_literal: true

require "stronger_parameters/constraints/date_time_constraint"

module StrongerParameters
  class DateTimeIso8601Constraint < DateTimeConstraint
    def initialize(use_zone: false)
      super(format: :iso8601, use_zone:)
    end
  end
end
