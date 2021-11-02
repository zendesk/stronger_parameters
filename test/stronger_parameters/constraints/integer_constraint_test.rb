# frozen_string_literal: true
require_relative '../../test_helper'

SingleCov.covered!

describe 'integer parameter constraints' do
  subject { ActionController::Parameters.integer }

  permits 123
  permits 2**64
  permits '123', as: 123
  permits '-123', as: -123
  permits ' 123', as: 123

  rejects 'abc'
  rejects Date.today
  rejects Time.now
  rejects nil
  rejects '   '
end
