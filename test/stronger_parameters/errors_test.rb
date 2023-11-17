# frozen_string_literal: true
require_relative "../test_helper"

SingleCov.covered!

describe StrongerParameters::InvalidValue do
  it "has a nice message" do
    error = StrongerParameters::InvalidValue.new(1, "blob")
    error.message.must_equal "blob"
    error.value.must_equal 1
  end
end

describe StrongerParameters::InvalidParameter do
  it "has a nice message" do
    error = StrongerParameters::InvalidParameter.new(StrongerParameters::InvalidValue.new(1, "bla"), "blob")
    error.message.must_equal "Invalid parameter: blob bla"
    error.key.must_equal "blob"
    error.value.must_equal 1
  end
end
