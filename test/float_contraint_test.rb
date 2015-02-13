require_relative 'test_helper'

describe 'float parameter constraints' do
  subject { ActionController::Parameters.float }

  permits "1.2", as: 1.2
  permits "-1.2", as: -1.2
  permits 1.2
  permits -1.2

  rejects 1
  rejects '1'
  rejects '-1'
  rejects 'abc'
  rejects '1.2.3'
  rejects '.3'
  rejects '3.'
  rejects true
end
