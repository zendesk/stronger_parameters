require_relative 'test_helper'

describe 'operator parameter constraints' do
  describe 'OR types' do
    subject { ActionController::Parameters.integer | ActionController::Parameters.string }

    permits 'abc'
    permits '123', :as => 123

    rejects Date.today
    rejects Time.now
    rejects nil
  end

  describe 'AND types' do
    subject { ActionController::Parameters.string & ActionController::Parameters.integer }

    permits '123', :as => 123

    rejects 123
    rejects 'abc'
    rejects nil
  end
end
