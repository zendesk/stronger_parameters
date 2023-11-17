# frozen_string_literal: true
require_relative "../../test_helper"

SingleCov.covered!

describe "nil_string parameter constraints" do
  subject { ActionController::Parameters.nil_string }

  permits "", as: nil
  permits "undefined", as: nil
  permits nil

  rejects "foo"
end
