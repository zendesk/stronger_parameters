# frozen_string_literal: true

require_relative "../../test_helper"

SingleCov.covered!

describe StrongerParameters::PresentConstraint do
  subject { ActionController::Parameters.present }

  permits "hello"
  permits " hello "
  permits ["hello"]
  permits [""]
  permits({key: "value"}, as: {"key" => "value"})
  permits 0
  permits true

  rejects ""
  rejects " \t\n"
  rejects "\u00a0"
  rejects []
  rejects({})
  rejects nil
  rejects false

  it "preserves the original value" do
    value = ["hello"]
    subject.value(value).must_be_same_as value
  end

  it "explains why a blank value is invalid" do
    result = subject.value("")
    result.value.must_equal ""
    result.message.must_equal "must not be empty"
  end
end
