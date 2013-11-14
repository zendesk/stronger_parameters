require_relative 'test_helper'

describe 'enum parameter constraints' do
  subject { ActionController::Parameters.enumeration('abc', 123) }

  permits 'abc'
  permits 123

  rejects 'abcd'
  rejects '123'
  rejects 1234
end
