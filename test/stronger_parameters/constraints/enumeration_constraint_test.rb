# frozen_string_literal: true
require_relative '../../test_helper'

SingleCov.covered!

describe 'enum parameter constraints' do
  subject { ActionController::Parameters.enumeration('abc', 123) }

  permits 'abc'
  permits 123

  rejects 'abcd'
  rejects '123'
  rejects 1234
  rejects nil

  describe "#==" do
    it "is the same with same limit" do
      subject.must_equal StrongerParameters::EnumerationConstraint.new('abc', 123)
    end

    it "is not the same with different limit" do
      subject.wont_equal StrongerParameters::EnumerationConstraint.new(123)
    end
  end
end
