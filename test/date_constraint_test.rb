require_relative 'test_helper'

describe 'date parameter constraints' do
  subject { ActionController::Parameters.datetime }

  permits "2015-03-31", as: DateTime.parse("2015-03-31")

  rejects "2015-03-32"  # Invalid day
  rejects "2015-00-32"  # Invalid month
end
