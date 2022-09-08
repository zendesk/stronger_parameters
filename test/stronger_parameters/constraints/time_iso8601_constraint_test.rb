# frozen_string_literal: true
require_relative '../../test_helper'

SingleCov.covered!

describe 'date parameter constraints' do
  subject { ActionController::Parameters.time_iso8601 }

  permits "2018-04-12T08:53:18+00:00", as: Time.iso8601("2018-04-12T08:53:18+00:00")
  permits "2018-04-12T08:53:18Z", as: Time.iso8601("2018-04-12T08:53:18Z")

  rejects []
  rejects 123
  rejects nil
  rejects "2018-04-12" # missing time component
  rejects "20180412T085318Z" # missing seperators
  rejects "2018-W15-4"
  rejects "2018-102"
  rejects "2015-03-31T14:34:56Zxxx"
end
