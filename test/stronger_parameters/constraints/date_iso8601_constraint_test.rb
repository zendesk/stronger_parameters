# frozen_string_literal: true
require_relative "../../test_helper"

SingleCov.covered!

describe "date_iso8601 parameter constraints" do
  subject { ActionController::Parameters.date_iso8601 }

  permits "2018-04-12", as: Date.iso8601("2018-04-12")
  permits "2018-04-12T08:53:18+00:00", as: Date.iso8601("2018-04-12T08:53:18+00:00")
  permits "2018-04-12T08:53:18Z", as: Date.iso8601("2018-04-12T08:53:18Z")
  permits "20180412T085318Z", as: Date.iso8601("20180412T085318Z")
  permits "2018-W15-4", as: Date.iso8601("2018-W15-4")
  permits "2018-102", as: Date.iso8601("2018-102")

  rejects []
  rejects 123
  rejects nil
  rejects "2015-03-32"  # Invalid day
  rejects "2015-00-15"  # Invalid month
  rejects "2015-03-31T14:34:56Zxxx"
end
