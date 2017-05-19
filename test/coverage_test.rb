# frozen_string_literal: true
require_relative 'test_helper'

SingleCov.not_covered! # not testing any code in lib/

describe "Coverage" do
  it "does not let users add new untested code" do
    SingleCov.assert_used
  end

  it "does not let users add new untested files" do
    SingleCov.assert_tested
  end
end
