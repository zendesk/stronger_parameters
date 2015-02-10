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

  describe ".action_on_invalid_parameters" do
    around do |test|
      begin
        old = ActionController::Parameters.action_on_invalid_parameters
        test.call
      ensure
        ActionController::Parameters.action_on_invalid_parameters = old
      end
    end

    it "calls a block on mismatch" do
      calls = []
      ActionController::Parameters.action_on_invalid_parameters = lambda { |*args| calls << args }
      result = params(:value => "a").permit(:value => ActionController::Parameters.integer32)
      calls.size.must_equal 1
      calls[0].size.must_equal 2
      calls[0][0].value.must_equal "a"
      calls[0][0].message.must_equal "must be an integer"
      calls[0][1].must_equal "value"
      result.must_equal "value" => "a"
    end

    it "does nothing on nil" do
      ActionController::Parameters.action_on_invalid_parameters = nil
      result = params(:value => "a").permit(:value => ActionController::Parameters.integer32)
      result.must_equal "value" => "a"
    end

    it "raises on raise" do
      assert_raises StrongerParameters::InvalidParameter do
        params(:value => "a").permit(:value => ActionController::Parameters.integer32)
      end
    end
  end
end
