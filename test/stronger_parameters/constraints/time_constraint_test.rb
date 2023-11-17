# frozen_string_literal: true

require_relative "../../test_helper"

SingleCov.covered!

describe "time parameter constraints" do
  subject { ActionController::Parameters.time }

  permits Time.parse("2015-03-31"), as: Time.parse("2015-03-31")
  permits "2015-03-31", as: Time.parse("2015-03-31")
  permits "2015-03-31T14:34:56Z", as: Time.parse("2015-03-31T14:34:56Z")

  rejects []
  rejects 123
  rejects nil
  rejects "2015-03-32"  # Invalid day
  rejects "2015-00-15"  # Invalid month
end
