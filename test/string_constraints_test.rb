require_relative 'test_helper'

describe 'string parameter constraints' do
  subject { ActionController::Parameters.string }

  permits 'abc'

  rejects 123
  rejects Date.today
  rejects Time.now
  rejects nil

  it 'rejects strings that are too long' do
    assert_rejects(:value) { params(:value => '123').permit(:value => ActionController::Parameters.string(:max_length => 2)) }
  end
end
