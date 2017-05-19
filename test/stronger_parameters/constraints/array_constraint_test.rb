# frozen_string_literal: true
require_relative '../../test_helper'

SingleCov.covered! uncovered: 1

describe 'array parameter constraints' do
  subject { ActionController::Parameters.array(ActionController::Parameters.string) }

  permits ['a', 'b']

  rejects 'abc'
  rejects 123
  rejects [123, 456]
  rejects ['abc', 123]
  rejects nil
  rejects [nil]
end
