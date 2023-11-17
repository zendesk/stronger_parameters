# frozen_string_literal: true

require_relative "../../test_helper"

SingleCov.covered!

describe StrongerParameters::StringConstraint do
  subject { ActionController::Parameters.string }

  permits "abc"

  rejects 123
  rejects Date.today
  rejects Time.now
  rejects nil
  rejects "\xA1".dup.force_encoding("UTF-8")

  it "rejects strings that are too long" do
    assert_rejects(:value) { params(value: "123").permit(value: ActionController::Parameters.string(max_length: 2)) }
  end

  it "rejects strings that are too short" do
    assert_rejects(:value) { params(value: "1234").permit(value: ActionController::Parameters.string(min_length: 5)) }
  end

  describe "#==" do
    it "is the same when both are the same" do
      subject.must_equal ActionController::Parameters.string
      ActionController::Parameters.string(maximum_length: 1, minimum_length: 2).must_equal(
        ActionController::Parameters.string(maximum_length: 1, minimum_length: 2)
      )
    end

    it "is not the same when max is different" do
      subject.wont_equal ActionController::Parameters.string(maximum_length: 1)
    end

    it "is not the same when min is different" do
      subject.wont_equal ActionController::Parameters.string(minimum_length: 1)
    end
  end
end
