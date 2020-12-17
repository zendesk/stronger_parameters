# frozen_string_literal: true
require_relative '../test_helper'

SingleCov.covered!

describe StrongerParameters::Constraint do
  subject { StrongerParameters::Constraint.new }

  describe "#value" do
    permits 'abc'
  end

  describe "#==" do
    it "equals itself" do
      subject.must_equal subject
    end

    it "equals same class" do
      subject.must_equal StrongerParameters::Constraint.new
    end

    it "does not equal other class" do
      subject.wont_equal StrongerParameters::OrConstraint.new
    end
  end

  describe "#required?" do
    it "is false by default" do
      subject.required?.must_equal(false)
    end
  end
end

describe StrongerParameters::OrConstraint do
  subject { ActionController::Parameters.integer | ActionController::Parameters.string }

  permits 'abc'
  permits '123', as: 123

  rejects Date.today
  rejects Time.now
  rejects nil

  describe "multi-chain" do
    subject do
      ActionController::Parameters.integer |
      ActionController::Parameters.string |
      ActionController::Parameters.boolean
    end

    permits 'abc'
    permits true

    rejects Date.today
  end

  describe "#==" do
    it "equals other with same constraints" do
      subject.must_equal(ActionController::Parameters.integer | ActionController::Parameters.string)
    end

    it "does not equal other with different constraints ordering since they behave differently" do
      subject.wont_equal(ActionController::Parameters.string & ActionController::Parameters.integer)
    end
  end

  describe "#required?" do
    it "is true if all of the constraints are required" do
      subject = (
        ActionController::Parameters.string.required |
        ActionController::Parameters.integer.required
      )

      subject.required?.must_equal(true)
    end

    it "is false if one of the constrants is not required" do
      subject = (
        ActionController::Parameters.string.required |
        ActionController::Parameters.integer
      )

      subject.required?.must_equal(false)
    end
  end
end

describe StrongerParameters::AndConstraint do
  subject { ActionController::Parameters.string & ActionController::Parameters.integer }

  permits '123', as: 123

  rejects 123
  rejects 'abc'
  rejects nil

  describe "multi-chain" do
    subject do
      ActionController::Parameters.string &
      ActionController::Parameters.integer &
      ActionController::Parameters.lt(5)
    end

    permits '4', as: 4

    rejects '5'
  end

  describe "#==" do
    it "equals other with same constraints" do
      subject.must_equal(ActionController::Parameters.string & ActionController::Parameters.integer)
    end

    it "does not equal other with different constraints ordering since they behave differently" do
      subject.wont_equal(ActionController::Parameters.integer & ActionController::Parameters.string)
    end
  end

  describe "#required?" do
    it "is true if any of the constraints is required" do
      subject = (
        ActionController::Parameters.string.required &
        ActionController::Parameters.integer
      )

      subject.required?.must_equal(true)
    end

    it "is false if none of the constrants are required" do
      subject = (
        ActionController::Parameters.string &
        ActionController::Parameters.integer
      )

      subject.required?.must_equal(false)
    end
  end
end

describe StrongerParameters::RequiredConstraint do
  subject { ActionController::Parameters.string.required }

  rejects nil
  permits '123'
end
