require_relative 'test_helper'

describe StrongerParameters::Parameters do
  describe ".id" do
    subject { ActionController::Parameters.id }

    permits 123
    permits 2**64
    permits '123', :as => 123

    rejects -123
    rejects 'abc'
  end

  describe ".smallid" do
    subject { ActionController::Parameters.smallid }

    permits 123
    permits (2**32) - 1
    permits '123', :as => 123

    rejects -123
    rejects 2**32
    rejects 'abc'
  end
end
