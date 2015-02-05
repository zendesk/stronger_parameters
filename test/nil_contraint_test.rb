require_relative 'test_helper'

describe 'nil parameter constraints' do
  subject { ActionController::Parameters.nil }

  permits nil

  rejects 'abc'
  rejects 1
  rejects false
end
