# frozen_string_literal: true
require_relative '../test_helper'

SingleCov.covered! uncovered: 3 # rails if/else code and controller support which is tested in controller_test.rb

describe StrongerParameters::Parameters do
  describe ".anything" do
    subject { ActionController::Parameters.anything }

    permits '1'
    permits 1
    permits []
  end

  describe ".nil" do
    subject { ActionController::Parameters.nil }

    permits nil
    rejects 1
    rejects false
  end

  describe ".string" do
    subject { ActionController::Parameters.string }

    permits "a"
    rejects 1
  end

  describe ".regexp" do
    subject { ActionController::Parameters.regexp(/foo/) }

    permits "xfoox"
    rejects "bar"
  end

  describe ".lte" do
    subject { ActionController::Parameters.lte(4) }

    permits 4
    rejects 5
  end

  describe ".gt" do
    subject { ActionController::Parameters.gt(4) }

    permits 5
    rejects 4
  end

  describe ".gte" do
    subject { ActionController::Parameters.gte(4) }

    permits 4
    rejects 3
  end

  describe ".enumeration" do
    subject { ActionController::Parameters.enumeration(1, 2) }

    permits 1
    permits 2
    rejects 4
  end

  describe ".boolean" do
    subject { ActionController::Parameters.boolean }

    permits true
    permits false
    rejects nil
    permits 1, as: true
  end

  describe ".float" do
    subject { ActionController::Parameters.float }

    permits 1.0
    rejects "X"
  end

  describe ".array" do
    subject { ActionController::Parameters.array(ActionController::Parameters.id) }

    permits [1, 2]
    rejects ["X"]
    rejects "X"
  end

  describe ".map" do
    subject { ActionController::Parameters.map(foo: ActionController::Parameters.id) }

    permits({foo: 1}, as: {"foo" => 1})
    rejects 1
  end

  describe ".nil_string" do
    subject { ActionController::Parameters.nil_string }

    permits "undefined", as: nil
    rejects 1
  end

  describe ".datetime" do
    subject { ActionController::Parameters.datetime }

    permits "2016-01-01 00:00:00 +0000", as: Time.parse("2016-01-01 00:00:00 +0000")
    rejects 1
  end

  describe ".file" do
    subject { ActionController::Parameters.file }

    permits StringIO.new
    rejects 1
  end

  describe ".decimal" do
    subject { ActionController::Parameters.decimal 4, 2 }

    permits "12.34", as: BigDecimal("12.34")
    rejects "12345.12"
  end

  describe ".hex" do
    subject { ActionController::Parameters.hex }

    permits "ab125"
    rejects "abg"
  end

  describe ".bigid" do
    subject { ActionController::Parameters.bigid }

    permits '1', as: 1
    permits 1
    permits 2**63 - 1

    rejects(-1)
    rejects 'a'
    rejects 2**63
  end

  describe ".id" do
    subject { ActionController::Parameters.id }

    permits '1', as: 1
    permits 1
    permits 2**31 - 1

    rejects(-1)
    rejects 'a'
    rejects 2**31
  end

  describe ".ubigid" do
    subject { ActionController::Parameters.ubigid }

    permits '1', as: 1
    permits 1
    permits 2**64 - 1

    rejects(-1)
    rejects 'a'
    rejects 2**64
  end

  describe ".uid" do
    subject { ActionController::Parameters.uid }

    permits '1', as: 1
    permits 1
    permits 2**32 - 1

    rejects(-1)
    rejects 'a'
    rejects 2**32
  end

  describe ".integer32" do
    subject { ActionController::Parameters.integer32 }

    permits '1', as: 1
    permits 2**31 - 1
    permits(-2**31)

    rejects 'a'
    rejects 2**31
    rejects(-2**31 - 1)
  end

  describe ".integer64" do
    subject { ActionController::Parameters.integer64 }

    permits '1', as: 1
    permits 2**63 - 1
    permits(-2**63)

    rejects 'a'
    rejects 2**63
    rejects(-2**63 - 1)
  end

  describe ".action_on_invalid_parameters" do
    around do |test|
      old = ActionController::Parameters.action_on_invalid_parameters
      test.call
    ensure
      ActionController::Parameters.action_on_invalid_parameters = old
    end

    it "calls a block on mismatch" do
      calls = []
      ActionController::Parameters.action_on_invalid_parameters = lambda { |*args| calls << args }
      result = params(value: "a").permit(value: ActionController::Parameters.integer32).to_h
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
        result = params(value: "a").permit(value: ActionController::Parameters.integer32).to_h
        result.must_equal "value" => "a"
      end
      log.must_include "value must be an integer, but was: \"a\""
    end

    it "raises on default" do
      assert_raises StrongerParameters::InvalidParameter do
        params(value: "a").permit(value: ActionController::Parameters.integer32)
      end
    end

    it "raises on :raise" do
      ActionController::Parameters.action_on_invalid_parameters = :raise
      assert_raises StrongerParameters::InvalidParameter do
        params(value: "a").permit(value: ActionController::Parameters.integer32)
      end
    end

    it "fails on unknown" do
      ActionController::Parameters.action_on_invalid_parameters = :sdfssfd
      assert_raises ArgumentError do
        params(value: "a").permit(value: ActionController::Parameters.integer32)
      end
    end
  end

  describe "mixing non constraints" do
    it "passes normal" do
      params(foo: "b", value: "a").permit(:value).to_h.must_equal "value" => "a"
    end

    it "passes nested constraints in non-constraint" do
      params(value: {key: 123}).permit(value: {key: ActionController::Parameters.integer32}).to_h.
        must_equal "value" => {"key" => 123}
    end

    it "fails nested constraints in non-constraint" do
      assert_raises StrongerParameters::InvalidParameter do
        params(value: {key: "xxx"}).permit(value: {key: ActionController::Parameters.integer32}).to_h
      end
    end

    it "passes nested constraints in non-constraint array" do
      params(value: [{key: 123}]).permit(value: [{key: ActionController::Parameters.integer32}]).to_h.
        must_equal "value" => [{"key" => 123}]
    end

    it "fails nested constraints in non-constraint array" do
      assert_raises StrongerParameters::InvalidParameter do
        params(value: [{key: "xxx"}]).permit(value: [{key: ActionController::Parameters.integer32}])
      end
    end

    describe "requireds" do
      it "does not pass if a required parameter is not supplied" do
        error = assert_raises StrongerParameters::InvalidParameter do
          params({}).permit(value: ActionController::Parameters.string.required)
        end

        assert_match("value must be present", error.message)
      end
    end

    describe "nils" do
      def pass_nil_as_constrain
        params(value: nil).permit(value: ActionController::Parameters.integer32)
      end

      def with_allow_nil_for_everything(value = true)
        old = ActionController::Parameters.allow_nil_for_everything
        ActionController::Parameters.allow_nil_for_everything = value
        yield
      ensure
        ActionController::Parameters.allow_nil_for_everything = old
      end

      it "passes with nil for non-constraints" do
        params(value: nil).permit(value: [{key: ActionController::Parameters.integer32}])
      end

      it "does not pass with nil for constraints" do
        assert_raises StrongerParameters::InvalidParameter do
          pass_nil_as_constrain
        end
      end

      it "passes with nil for constraints when allow_nil_for_everything is on" do
        with_allow_nil_for_everything do
          pass_nil_as_constrain.to_h.must_equal("value" => nil)
        end
      end

      it "does not create keys if parameter is not supplied and allow_nil_for_everything is on" do
        with_allow_nil_for_everything do
          params({}).permit(value: ActionController::Parameters.string).to_h.must_equal({})
        end
      end
    end
  end
end
