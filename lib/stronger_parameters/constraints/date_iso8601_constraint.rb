# frozen_string_literal: true

require "stronger_parameters/constraints/date_constraint"

module StrongerParameters
  class DateIso8601Constraint < DateConstraint
    def initialize = super(format: :iso8601)
  end
end
