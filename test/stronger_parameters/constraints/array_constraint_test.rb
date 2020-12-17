# frozen_string_literal: true
require_relative '../../test_helper'

SingleCov.covered!

describe StrongerParameters::ArrayConstraint do
  subject { ActionController::Parameters.array(ActionController::Parameters.string) }

  permits ['a', 'b']

  rejects 'abc'
  rejects 123
  rejects [123, 456]
  rejects ['abc', 123]
  rejects nil
  rejects [nil]

  describe '#==' do
    it "is the same with same constraints" do
      subject.must_equal ActionController::Parameters.array(ActionController::Parameters.string)
    end

    it "is not the same with different constraints" do
      subject.wont_equal ActionController::Parameters.array(ActionController::Parameters.integer)
    end
  end
end
