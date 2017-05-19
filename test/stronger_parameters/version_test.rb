# frozen_string_literal: true
require_relative '../test_helper'

SingleCov.not_covered! # loaded before SingleCov is loaded

describe StrongerParameters::VERSION do
  it "is a version" do
    StrongerParameters::VERSION.must_match(/^\d+\.\d+\.\d+/)
  end
end
