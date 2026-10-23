# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "../../support/date_time_format_tests"

SingleCov.covered!

describe StrongerParameters::TimeIso8601Constraint do
  extend DateTimeFormatTests

  subject { StrongerParameters::TimeIso8601Constraint.new }

  validates_format_matrix(:time, format: :iso8601)

  it "inherits TimeConstraint" do
    subject.must_be_kind_of StrongerParameters::TimeConstraint
  end
end
