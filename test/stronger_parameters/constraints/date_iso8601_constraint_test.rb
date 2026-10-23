# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "../../support/date_time_format_tests"

SingleCov.covered!

describe StrongerParameters::DateIso8601Constraint do
  extend DateTimeFormatTests

  subject { StrongerParameters::DateIso8601Constraint.new }

  validates_format_matrix(:date, format: :iso8601)

  it "inherits DateConstraint" do
    subject.must_be_kind_of StrongerParameters::DateConstraint
  end
end
