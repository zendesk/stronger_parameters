require_relative 'test_helper'

describe 'comparison parameter constraints' do
  describe 'less-than types' do
    subject { ActionController::Parameters.lt(2) }

    permits 1
    rejects 2
    rejects 3
  end

  describe 'less-than-or-equal types' do
    subject { ActionController::Parameters.lte(2) }

    permits 1
    permits 2
    rejects 3
  end

  describe 'greater-than types' do
    subject { ActionController::Parameters.gt(2) }

    rejects 1
    rejects 2
    permits 3
  end

  describe 'greater-than-or-equal types' do
    subject { ActionController::Parameters.gte(2) }

    rejects 1
    permits 2
    permits 3
  end
end
