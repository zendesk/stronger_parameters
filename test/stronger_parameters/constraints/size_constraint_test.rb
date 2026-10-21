# frozen_string_literal: true

require_relative "../../test_helper"

SingleCov.covered!

describe StrongerParameters::SizeConstraint do
  subject { ActionController::Parameters.size(1..2) }

  permits [1]
  permits [1, 2]
  rejects []
  rejects [1, 2, 3]
  rejects "foo"
  rejects({a: "1"})
  rejects nil

  it "reports non-array inputs" do
    subject.value("foo").message.must_equal "must be an array"
  end

  it "reports both bounds" do
    subject.value([]).message.must_equal "must have between 1 and 2 elements"
  end

  describe "an exact size" do
    subject { ActionController::Parameters.size(1..1) }

    permits [1]
    rejects []
    rejects [1, 2]

    it "reports the exact size" do
      subject.value([]).message.must_equal "must have exactly 1 element"
      ActionController::Parameters.size(2..2).value([]).message.must_equal "must have exactly 2 elements"
    end
  end

  describe "an endless range" do
    subject { ActionController::Parameters.size(1..) }

    permits [1]
    permits [1, 2]
    rejects []

    it "reports the minimum size" do
      subject.value([]).message.must_equal "must have at least 1 element"
    end
  end

  describe "a beginless range" do
    subject { ActionController::Parameters.size(..1) }

    permits []
    permits [1]
    rejects [1, 2]

    it "reports the maximum size" do
      subject.value([1, 2]).message.must_equal "must have at most 1 element"
    end
  end

  describe "an exclusive range" do
    subject { ActionController::Parameters.size(1...2) }

    permits [1]
    rejects [1, 2]
  end

  describe "combined with an array constraint" do
    subject do
      ActionController::Parameters.array(ActionController::Parameters.integer) & ActionController::Parameters.size(1..2)
    end

    permits ["1", "2"], as: [1, 2]
    rejects []
    rejects ["1", "2", "3"]
    rejects ["a"]
  end
end
