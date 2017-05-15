require_relative '../test_helper'
require 'stronger_parameters/controller_support/parameter_whitelist'

describe StrongerParameters::ControllerSupport::ParameterWhitelist do
  class WhitelistControllerTester < ActionController::Base
    include StrongerParameters::ControllerSupport::ParameterWhitelist

    def arrrr; end
  end

  Parameters = ActionController::Parameters

  def whitelist_without_raising
    old = Parameters.action_on_invalid_parameters
    Parameters.action_on_invalid_parameters = :log
    capture_log do
      @controller.send(:whitelist_parameters)
    end
  ensure
    Parameters.action_on_invalid_parameters = old
  end

  before do
    WhitelistControllerTester.allowed_parameters.clear
    WhitelistControllerTester.allowed_parameters[:all] = StrongerParameters::ControllerSupport::ParameterWhitelist::DEFAULT_ALLOWED.dup
    @oldu = Parameters.action_on_unpermitted_parameters
    Parameters.action_on_unpermitted_parameters = :log # same as dev/production
  end

  after do
    WhitelistControllerTester.log_stronger_parameter_violations = false
    WhitelistControllerTester.instance_variable_set(:@allowed_parameters, nil)
    Parameters.action_on_unpermitted_parameters = @oldu
  end

  describe 'inheritance' do
    class ChildController < WhitelistControllerTester
    end

    before do
      WhitelistControllerTester.allow_parameters :create, first: Parameters.string
      WhitelistControllerTester.log_stronger_parameter_violations!
      ChildController.allow_parameters :create, last: Parameters.string
    end

    it 'inherits from parent to child' do
      assert_instance_of StrongerParameters::StringConstraint, WhitelistControllerTester.allowed_parameters_for(:create)[:first]
      assert_instance_of StrongerParameters::StringConstraint, ChildController.allowed_parameters_for(:create)[:first]
      assert_equal true, ChildController.log_stronger_parameter_violations
    end

    it 'does not inherit from child to parent' do
      assert_nil WhitelistControllerTester.allowed_parameters_for(:create)[:last]
      assert_instance_of StrongerParameters::StringConstraint, ChildController.allowed_parameters_for(:create)[:last]
    end
  end

  describe 'parameter whitelisting' do
    before do
      WhitelistControllerTester.allow_parameters :all, user_id: Parameters.integer
      WhitelistControllerTester.allow_parameters :foo, ticket_id: Parameters.integer
      WhitelistControllerTester.allow_parameters :bar, group_id: Parameters.integer
    end

    it 'allows general whitelisting' do
      assert_equal Parameters.integer, WhitelistControllerTester.allowed_parameters_for(:foo)[:user_id]
      assert_equal Parameters.integer, WhitelistControllerTester.allowed_parameters_for(:bar)[:user_id]
    end

    it 'allows specific whitelisting' do
      assert_equal Parameters.integer, WhitelistControllerTester.allowed_parameters_for(:foo)[:ticket_id]
      assert_nil WhitelistControllerTester.allowed_parameters_for(:foo)[:group_id]

      assert_equal Parameters.integer, WhitelistControllerTester.allowed_parameters_for(:bar)[:group_id]
      assert_nil WhitelistControllerTester.allowed_parameters_for(:bar)[:ticket_id]
    end
  end

  describe 'sugar' do
    it 'turns Array into Parameters.array' do
      WhitelistControllerTester.allow_parameters :foo, ticket: [Parameters.integer]
      constraint = WhitelistControllerTester.allowed_parameters_for(:foo)[:ticket].constraints.first
      assert_instance_of StrongerParameters::ArrayConstraint, constraint
      assert_equal Parameters.integer, constraint.item_constraint
    end

    it 'turns Hash into Parameters.map' do
      WhitelistControllerTester.allow_parameters :foo, ticket: { id: Parameters.integer }
      constraint = WhitelistControllerTester.allowed_parameters_for(:foo)[:ticket]
      assert_instance_of StrongerParameters::HashConstraint, constraint
      assert_equal({ 'id' => Parameters.integer }, constraint.constraints)
    end
  end

  describe 'with prevent_nil_values_in_params' do
    before do
      WhitelistControllerTester.allow_parameters :show, something: {
        test: {
          all: Parameters.anything,
          day: Parameters.anything
        }
      }
      @controller = WhitelistControllerTester.new
      @controller.request = ActionController::TestRequest.new('CONTENT_TYPE' => 'application/json')
      params = { action: 'show', controller: 'test' }.merge(subject)
      @controller.params =
        if Rails::VERSION::MAJOR <= 4
          ActionDispatch::Request::Utils.deep_munge(params)
        else
          @controller.request.send(:deep_munge, params)
        end
      @controller.response = ActionController::TestResponse.new
      whitelist_without_raising
    end

    describe 'with child empty hash' do
      subject { { something: { test: {} } } }

      it 'does not remove test' do
        assert @controller.params[:something].key?(:test)
      end
    end

    describe 'with child empty array' do
      subject { { something: { test: [] } } }

      it 'does not remove test' do
        assert @controller.params[:something].key?(:test)
      end
    end

    describe 'with empty array' do
      subject { { something: [] } }

      it 'does not remove something' do
        assert @controller.params.key?(:something)
      end
    end

    describe 'with empty hash' do
      subject { { something: {} } }

      it 'does not remove something' do
        assert @controller.params.key?(:something)
      end
    end
  end

  describe 'parameter filtering' do
    before do
      WhitelistControllerTester.allow_parameters :show, something: Parameters.anything
      WhitelistControllerTester.allow_parameters :create, :anything
      @controller = WhitelistControllerTester.new
      @controller.request = ActionController::TestRequest.new({})
      @controller.response = ActionController::TestResponse.new
      @controller.params = {
        id: '4',
        action: 'show',
        controller: 'test',
        format: 'png',
        authenticity_token: 'auth'
      }
      whitelist_without_raising
    end

    it 'does not filter special cases' do
      assert @controller.params.key?(:action)
      assert @controller.params.key?(:controller)
      assert @controller.params.key?(:format)
      assert @controller.params.key?(:authenticity_token)
    end

    describe 'headers' do
      before { @controller.response.headers['X-StrongerParameters-API-Warn'] = nil }

      it 'filters false values and send warn' do
        @controller.params[:invalid] = false
        Rails.configuration.stronger_parameters_violation_header = 'X-StrongerParameters-API-Warn'
        whitelist_without_raising

        assert !@controller.params.key?(:invalid)
        refute @controller.response.headers['X-StrongerParameters-API-Warn'].nil?
      end

      it 'filters nil values and send warn' do
        @controller.params[:invalid] = nil
        Rails.configuration.stronger_parameters_violation_header = 'X-StrongerParameters-API-Warn'
        whitelist_without_raising

        assert !@controller.params.key?(:invalid)
        refute @controller.response.headers['X-StrongerParameters-API-Warn'].nil?
      end

      it 'filters values and does not send header if not configured' do
        @controller.params[:invalid] = false
        Rails.configuration.stronger_parameters_violation_header = nil
        whitelist_without_raising

        assert     !@controller.params.key?(:invalid)
        assert_nil @controller.response.headers['X-StrongerParameters-API-Warn']
      end
    end

    it 'filters specific actions' do
      @controller.params.merge!(action: 'show', everything: 'bleh', something: 'hello')
      whitelist_without_raising

      refute @controller.params.key?(:everything)
      assert @controller.params.key?(:something)

      @controller.params.merge!(action: 'create', everything: 'bleh', something: 'hello')
      whitelist_without_raising

      assert @controller.params.key?(:everything)
      assert @controller.params.key?(:something)
    end

    it 'alsos filter request.params' do
      @controller.params.merge!(action: 'show', everything: 'bleh', something: 'hello')
      whitelist_without_raising

      refute @controller.params.key?(:everything)
      assert @controller.params.key?(:something)

      refute @controller.request.params.key?(:everything)
      assert @controller.request.params.key?(:something)
    end

    it 'raises if not declared' do
      assert_raises(KeyError) do
        @controller.params.merge!(action: 'arrrr', everything: 'bleh', something: 'hello')
        whitelist_without_raising
      end
    end

    it 'raises if trying to add to :anything' do
      assert_raises(ArgumentError) do
        WhitelistControllerTester.allow_parameters :create, bar: Parameters.boolean
        whitelist_without_raising
      end
    end
  end

  describe 'stronger_parameter violations' do
    before do
      WhitelistControllerTester.allow_parameters :show, foo: Parameters.integer
      @controller = WhitelistControllerTester.new
      @controller.request = ActionController::TestRequest.new({})
      @controller.response = ActionController::TestResponse.new
      @controller.params = {
        action: 'show',
        controller: 'test',
        foo: 'bar'
      }
    end

    it 'does not allow the violation' do
      assert_raises(StrongerParameters::InvalidParameter) do
        @controller.send(:whitelist_parameters)
      end
    end

    it 'can allow the violations' do
      begin
        WhitelistControllerTester.log_stronger_parameter_violations!
        @controller.params = {
          action: 'show',
          controller: 'test',
          foo: 'bar',
          invalid: 'foo'
        }.with_indifferent_access

        whitelist_without_raising

        assert @controller.params.key?(:invalid)
      ensure
        WhitelistControllerTester.log_stronger_parameter_violations = false
      end
    end
  end
end
