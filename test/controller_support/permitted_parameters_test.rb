require_relative '../test_helper'
require 'stronger_parameters/controller_support/permitted_parameters'

describe StrongerParameters::ControllerSupport::PermittedParameters do
  class WhitelistControllerTester < ActionController::Base
    include StrongerParameters::ControllerSupport::PermittedParameters

    def arrrr; end
  end

  Parameters = ActionController::Parameters

  def permit_without_raising
    old = Parameters.action_on_invalid_parameters
    Parameters.action_on_invalid_parameters = :log
    capture_log do
      @controller.send(:permit_parameters)
    end
  ensure
    Parameters.action_on_invalid_parameters = old
  end

  def initialize_test_request(env = {})
    if Rails::VERSION::MAJOR >= 5
      ActionController::TestRequest.create.tap do |request|
        request.content_type = env['CONTENT_TYPE'] if env['CONTENT_TYPE']
      end
    else
      ActionController::TestRequest.new(env)
    end
  end

  def initialize_test_response
    if Rails::VERSION::MAJOR >= 5
      ActionDispatch::TestResponse.create
    else
      ActionController::TestResponse.new
    end
  end

  def normalize_params(params)
    if Rails::VERSION::MAJOR >= 5
      ActionDispatch::Request::Utils.normalize_encode_params(params)
    elsif Rails::VERSION::MAJOR == 4
      ActionDispatch::Request::Utils.deep_munge(params)
    else
      @controller.request.send(:deep_munge, params)
    end
  end

  before do
    if Rails::VERSION::MAJOR >= 5 && Rails::VERSION::MINOR > 0
      skip('PermittedParameters not compatible with Rails 5.1 or later')
    end

    permit_parameters = WhitelistControllerTester.send(:permit_parameters)
    permit_parameters.clear
    permit_parameters[:all] = StrongerParameters::ControllerSupport::PermittedParameters::DEFAULT_PERMITTED.dup
    WhitelistControllerTester.instance_variable_set(:@permit_parameters, permit_parameters)
    @oldu = Parameters.action_on_unpermitted_parameters
    Parameters.action_on_unpermitted_parameters = :log # same as dev/production
  end

  after do
    WhitelistControllerTester.log_unpermitted_parameters = false
    WhitelistControllerTester.instance_variable_set(:@permit_parameters, nil)
    Parameters.action_on_unpermitted_parameters = @oldu
  end

  describe 'inheritance' do
    class ChildController < WhitelistControllerTester
    end

    before do
      WhitelistControllerTester.permitted_parameters :create, first: Parameters.string
      WhitelistControllerTester.log_unpermitted_parameters!
      ChildController.permitted_parameters :create, last: Parameters.string
    end

    it 'inherits from parent to child' do
      assert_instance_of StrongerParameters::StringConstraint, WhitelistControllerTester.permitted_parameters_for(:create)[:first]
      assert_instance_of StrongerParameters::StringConstraint, ChildController.permitted_parameters_for(:create)[:first]
      assert_equal true, ChildController.log_unpermitted_parameters
    end

    it 'does not inherit from child to parent' do
      assert_nil WhitelistControllerTester.permitted_parameters_for(:create)[:last]
      assert_instance_of StrongerParameters::StringConstraint, ChildController.permitted_parameters_for(:create)[:last]
    end
  end

  describe 'permitted parameters' do
    before do
      WhitelistControllerTester.permitted_parameters :all, user_id: Parameters.integer
      WhitelistControllerTester.permitted_parameters :foo, ticket_id: Parameters.integer
      WhitelistControllerTester.permitted_parameters :bar, group_id: Parameters.integer
    end

    it 'allows general whitelisting' do
      assert_equal Parameters.integer, WhitelistControllerTester.permitted_parameters_for(:foo)[:user_id]
      assert_equal Parameters.integer, WhitelistControllerTester.permitted_parameters_for(:bar)[:user_id]
    end

    it 'allows specific whitelisting' do
      assert_equal Parameters.integer, WhitelistControllerTester.permitted_parameters_for(:foo)[:ticket_id]
      assert_nil WhitelistControllerTester.permitted_parameters_for(:foo)[:group_id]

      assert_equal Parameters.integer, WhitelistControllerTester.permitted_parameters_for(:bar)[:group_id]
      assert_nil WhitelistControllerTester.permitted_parameters_for(:bar)[:ticket_id]
    end
  end

  describe 'sugar' do
    it 'turns Array into Parameters.array' do
      WhitelistControllerTester.permitted_parameters :foo, ticket: [Parameters.integer]
      constraint = WhitelistControllerTester.permitted_parameters_for(:foo)[:ticket]
      assert_instance_of StrongerParameters::ArrayConstraint, constraint
      assert_equal Parameters.integer, constraint.item_constraint
    end

    it 'turns Hash into Parameters.map' do
      WhitelistControllerTester.permitted_parameters :foo, ticket: { id: Parameters.integer }
      constraint = WhitelistControllerTester.permitted_parameters_for(:foo)[:ticket]
      assert_instance_of StrongerParameters::HashConstraint, constraint
      assert_equal({ 'id' => Parameters.integer }, constraint.constraints)
    end
  end

  describe 'with prevent_nil_values_in_params' do
    before do
      WhitelistControllerTester.permitted_parameters :show, something: {
        test: {
          all: Parameters.anything,
          day: Parameters.anything
        }
      }
      @controller = WhitelistControllerTester.new
      @controller.request = initialize_test_request('CONTENT_TYPE' => 'application/json')
      params = { action: 'show', controller: 'test' }.merge(subject)
      @controller.params = normalize_params(params)
      @controller.response = initialize_test_request
      permit_without_raising
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
      WhitelistControllerTester.permitted_parameters :show, something: Parameters.anything, user: { name: Parameters.string }
      WhitelistControllerTester.permitted_parameters :create, :anything
      @controller = WhitelistControllerTester.new
      @controller.request = initialize_test_request
      @controller.response = initialize_test_response
      @controller.params = {
        id: '4',
        action: 'show',
        controller: 'test',
        format: 'png',
        authenticity_token: 'auth'
      }
      permit_without_raising
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
        permit_without_raising

        assert !@controller.params.key?(:invalid)
        refute @controller.response.headers['X-StrongerParameters-API-Warn'].nil?
      end

      it 'filters nil values and send warn' do
        @controller.params[:invalid] = nil
        Rails.configuration.stronger_parameters_violation_header = 'X-StrongerParameters-API-Warn'
        permit_without_raising

        assert !@controller.params.key?(:invalid)
        refute @controller.response.headers['X-StrongerParameters-API-Warn'].nil?
      end

      it 'filters values and does not send header if not configured' do
        @controller.params[:invalid] = false
        Rails.configuration.stronger_parameters_violation_header = nil
        permit_without_raising

        assert     !@controller.params.key?(:invalid)
        assert_nil @controller.response.headers['X-StrongerParameters-API-Warn']
      end
    end

    it 'filters specific actions' do
      @controller.params.merge!(action: 'show', everything: 'bleh', something: 'hello')
      permit_without_raising

      refute @controller.params.key?(:everything)
      assert @controller.params.key?(:something)

      @controller.params.merge!(action: 'create', everything: 'bleh', something: 'hello')
      permit_without_raising

      assert @controller.params.key?(:everything)
      assert @controller.params.key?(:something)
    end

    it 'alsos filter request.params' do
      @controller.params.merge!(action: 'show', everything: 'bleh', something: 'hello')
      permit_without_raising

      refute @controller.params.key?(:everything)
      assert @controller.params.key?(:something)

      refute @controller.request.params.key?(:everything)
      assert @controller.request.params.key?(:something)
    end

    it 'raises if not declared' do
      assert_raises(KeyError) do
        @controller.params.merge!(action: 'arrrr', everything: 'bleh', something: 'hello')
        permit_without_raising
      end
    end

    it 'raises if trying to add to :anything' do
      assert_raises(ArgumentError) do
        WhitelistControllerTester.permitted_parameters :create, bar: Parameters.boolean
        permit_without_raising
      end
    end
  end

  describe 'stronger_parameter violations' do
    before do
      WhitelistControllerTester.permitted_parameters :show, foo: Parameters.integer
      @controller = WhitelistControllerTester.new
      @controller.request = initialize_test_request
      @controller.response = initialize_test_response
      @controller.params = {
        action: 'show',
        controller: 'test',
        foo: 'bar'
      }
    end

    it 'does not permit the violation' do
      assert_raises(StrongerParameters::InvalidParameter) do
        @controller.send(:permit_parameters)
      end
    end

    it 'can permit the violations' do
      begin
        WhitelistControllerTester.log_unpermitted_parameters!
        @controller.params = {
          action: 'show',
          controller: 'test',
          foo: 'bar',
          invalid: 'foo'
        }.with_indifferent_access

        permit_without_raising

        assert @controller.params.key?(:invalid)
      ensure
        WhitelistControllerTester.log_unpermitted_parameters = false
      end
    end
  end
end
