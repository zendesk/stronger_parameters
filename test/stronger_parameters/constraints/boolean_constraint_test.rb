# frozen_string_literal: true
require_relative '../../test_helper'

SingleCov.covered!

describe 'boolean parameter constraints' do
  subject { ActionController::Parameters.boolean }

  permits true,    as: true
  permits 'true',  as: true
  permits 'True',  as: true
  permits 1,       as: true
  permits '1',     as: true
  permits 'on',    as: true

  permits false,   as: false
  permits 'false', as: false
  permits 'FALSE', as: false
  permits 0,       as: false
  permits '0',     as: false

  rejects 'foo'
  rejects nil
end
