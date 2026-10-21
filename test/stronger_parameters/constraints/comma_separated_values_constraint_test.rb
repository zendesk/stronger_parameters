# frozen_string_literal: true

require_relative "../../test_helper"

SingleCov.covered!

describe StrongerParameters::CommaSeparatedValuesConstraint do
  subject { ActionController::Parameters.csv(ActionController::Parameters.bigid) }

  permits "1,2,3", as: [1, 2, 3]
  permits "1, 2, 3", as: [1, 2, 3]
  permits "1, 2, 3, ", as: [1, 2, 3]
  permits "", as: []

  rejects "1, 2, 3, a"
  rejects [1, 2, 3]
  rejects 123
  rejects nil

  it "returns the item constraint's error" do
    result = subject.value("1, a, 3")
    result.value.must_equal "a"
    result.message.must_equal "must be an integer"
  end

  it "reports non-string inputs" do
    subject.value([]).message.must_equal "must be a string with comma separated values"
  end

  describe "with combined item constraints" do
    subject do
      ActionController::Parameters.csv(
        ActionController::Parameters.bigid | ActionController::Parameters.enum("suspended", "deleted")
      )
    end

    permits "1, 2, 3, suspended", as: [1, 2, 3, "suspended"]
    permits "1, 2, 3, deleted", as: [1, 2, 3, "deleted"]
    rejects "1, unknown"
  end
end
