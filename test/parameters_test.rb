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
    def capture_log
      io = StringIO.new
      old, Rails.logger = Rails.logger, Logger.new(io)
      yield
      io.string
    ensure
      Rails.logger = old
    end

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

    it "logs on log" do
      ActionController::Parameters.action_on_invalid_parameters = :log
      log = capture_log do
        result = params(:value => "a").permit(:value => ActionController::Parameters.integer32)
        result.must_equal "value" => "a"
      end
      log.must_include "value must be an integer, but was: \"a\""
    end

    it "raises on default" do
      assert_raises StrongerParameters::InvalidParameter do
        params(:value => "a").permit(:value => ActionController::Parameters.integer32)
      end
    end

    it "raises on :raise" do
      ActionController::Parameters.action_on_invalid_parameters = :raise
      assert_raises StrongerParameters::InvalidParameter do
        params(:value => "a").permit(:value => ActionController::Parameters.integer32)
      end
    end

    it "fails on unknown" do
      ActionController::Parameters.action_on_invalid_parameters = :sdfssfd
      assert_raises ArgumentError do
        params(:value => "a").permit(:value => ActionController::Parameters.integer32)
      end
    end
  end

  describe "mixing non constraints" do
    it "passes normal" do
      params(:foo => "b", :value => "a").permit(:value).must_equal "value" => "a"
    end

    it "passes nested contraints in non-constraint" do
      params(:value => {:key => 123}).permit(:value => {:key => ActionController::Parameters.integer32}).must_equal "value" => {"key" => 123}
    end

    it "fails nested contraints in non-constraint" do
      assert_raises StrongerParameters::InvalidParameter do
        params(:value => {:key => "xxx"}).permit(:value => {:key => ActionController::Parameters.integer32})
      end
    end

    it "passes nested contraints in non-constraint array" do
      params(:value => [{:key => 123}]).permit(:value => [{:key => ActionController::Parameters.integer32}]).must_equal "value" => [{"key" => 123}]
    end

    it "fails nested contraints in non-constraint array" do
      assert_raises StrongerParameters::InvalidParameter do
        params(:value => [{:key => "xxx"}]).permit(:value => [{:key => ActionController::Parameters.integer32}])
      end
    end

    describe "nils" do
      def pass_nil_as_constrain
        params(:value => nil).permit(:value => ActionController::Parameters.integer32)
      end

      it "passes with nil for non-constraints" do
        params(:value => nil).permit(:value => [{:key => ActionController::Parameters.integer32}])
      end

      it "does not pass with nil for constraints" do
        assert_raises StrongerParameters::InvalidParameter do
          pass_nil_as_constrain
        end
      end

      it "passes with nil for constraints when allow_nil_for_everything is on" do
        begin
          old, ActionController::Parameters.allow_nil_for_everything = ActionController::Parameters.allow_nil_for_everything, true
          pass_nil_as_constrain.must_equal("value" => nil)
        ensure
          ActionController::Parameters.allow_nil_for_everything = old
        end
      end
    end
  end
end
