require_relative 'test_helper'

describe 'hexadecimal parameter constraints' do
  subject { ActionController::Parameters.hex }

  permits 'DEADbeef'
  permits 'abcdef0123456789'

  rejects 'abcxyz'
  rejects ''
  rejects 123
  rejects false
  rejects [1]
  rejects a: :b
end
