# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "../../support/date_time_format_tests"

SingleCov.covered!

describe StrongerParameters::DateTimeIso8601Constraint do
  extend DateTimeFormatTests

  subject { StrongerParameters::DateTimeIso8601Constraint.new }

  validates_format_matrix(:datetime, format: :iso8601)

  it "inherits DateTimeConstraint" do
    subject.must_be_kind_of StrongerParameters::DateTimeConstraint
  end
end
