require_relative 'test_helper'

describe StrongerParameters::Parameters do
  describe ".bigid" do
    subject { ActionController::Parameters.bigid }

    permits '1', as: 1
    permits 1
    permits 2**63 - 1

    rejects -1
    rejects 'a'
    rejects 2**63
  end

  describe ".id" do
    subject { ActionController::Parameters.id }

    permits '1', as: 1
    permits 1
    permits 2**31 - 1

    rejects -1
    rejects 'a'
    rejects 2**31
  end

  describe ".ubigid" do
    subject { ActionController::Parameters.ubigid }

    permits '1', as: 1
    permits 1
    permits 2**64 - 1

    rejects -1
    rejects 'a'
    rejects 2**64
  end

  describe ".uid" do
    subject { ActionController::Parameters.uid }

    permits '1', as: 1
    permits 1
    permits 2**32 - 1

    rejects -1
    rejects 'a'
    rejects 2**32
  end

  describe ".integer32" do
    subject { ActionController::Parameters.integer32 }

    permits '1', as: 1
    permits 2**31 - 1
    permits -2**31

    rejects 'a'
    rejects 2**31
    rejects -2**31 - 1
  end

  describe ".integer64" do
    subject { ActionController::Parameters.integer64 }

    permits '1', as: 1
    permits 2**63 - 1
    permits -2**63

    rejects 'a'
    rejects 2**63
    rejects -2**63 - 1
  end
end
