# frozen_string_literal: true
require_relative '../../test_helper'

SingleCov.covered!

describe StrongerParameters::ComparisonConstraints do
  subject { StrongerParameters::ComparisonConstraints.new(2) }

  describe "#value" do
    it "warns users that it should not be used" do
      assert_raises(NotImplementedError) { subject.value(1) }
    end
  end

  describe "#==" do
    it "is the same with same limit" do
      subject.must_equal StrongerParameters::ComparisonConstraints.new(2)
    end

    it "is not the same with different limit" do
      subject.wont_equal StrongerParameters::ComparisonConstraints.new(3)
    end
  end
end

describe StrongerParameters::LessThanConstraint do
  subject { ActionController::Parameters.lt(2) }

  permits 1
  rejects 2
  rejects 3
end

describe StrongerParameters::LessThanOrEqualConstraint do
  subject { ActionController::Parameters.lte(2) }

  permits 1
  permits 2
  rejects 3
end

describe StrongerParameters::GreaterThanConstraint do
  subject { ActionController::Parameters.gt(2) }

  rejects 1
  rejects 2
  permits 3
end

describe StrongerParameters::GreaterThanOrEqualConstraint do
  subject { ActionController::Parameters.gte(2) }

  rejects 1
  permits 2
  permits 3
end
