# frozen_string_literal: true
require_relative '../../test_helper'
require 'stronger_parameters/controller_support/permitted_parameters'

SingleCov.covered! uncovered: 3

class WhitelistsController < ActionController::Base
  include StrongerParameters::ControllerSupport::PermittedParameters

  rescue_from(KeyError) do |e|
    render plain: e.message, status: :bad_request
  end

  def create
    head :ok
  end

  def index
    head :ok
  end

  def show
    raise "Should not get here"
  end
end

describe WhitelistsController do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  Parameters = ActionController::Parameters
  # rubocop:enable Lint/ConstantDefinitionInBlock

  before do
    # cannot use around since it is not ordered in rails 3.2
    @old_invalid = ActionController::Parameters.action_on_invalid_parameters
    ActionController::Parameters.action_on_invalid_parameters = :log
    @old_unpermitted = ActionController::Parameters.action_on_unpermitted_parameters
    ActionController::Parameters.action_on_unpermitted_parameters = :log
  end

  after do
    ActionController::Parameters.action_on_invalid_parameters = @old_invalid
    ActionController::Parameters.action_on_unpermitted_parameters = @old_unpermitted

    WhitelistsController.instance_variable_set(:@permit_parameters, nil)
    WhitelistsController.log_unpermitted_parameters = false
  end

  describe '.sugar' do
    it 'turns Array into Parameters.array' do
      WhitelistsController.permitted_parameters :foo, ticket: [Parameters.integer]
      constraint = WhitelistsController.permitted_parameters_for(:foo)[:ticket]
      assert_instance_of StrongerParameters::ArrayConstraint, constraint
      assert_equal Parameters.integer, constraint.item_constraint
    end

    it 'turns Hash into Parameters.map' do
      WhitelistsController.permitted_parameters :foo, ticket: { id: Parameters.integer }
      constraint = WhitelistsController.permitted_parameters_for(:foo)[:ticket]
      assert_instance_of StrongerParameters::HashConstraint, constraint
      assert_equal({ 'id' => Parameters.integer }, constraint.constraints)
    end
  end

  describe '.permitted_parameters' do
    before do
      WhitelistsController.permitted_parameters :all, user_id: Parameters.integer
      WhitelistsController.permitted_parameters :foo, ticket_id: Parameters.integer
      WhitelistsController.permitted_parameters :bar, group_id: Parameters.integer
      WhitelistsController.permitted_parameters :bar, nested: {a: Parameters.integer}
      WhitelistsController.permitted_parameters :bar, nested: {b: Parameters.integer}
    end

    it 'allows general whitelisting' do
      WhitelistsController.permitted_parameters_for(:foo)[:user_id].must_equal Parameters.integer
      WhitelistsController.permitted_parameters_for(:bar)[:user_id].must_equal Parameters.integer
    end

    it 'allows nested whitelisting' do
      WhitelistsController.permitted_parameters_for(:foo)[:ticket_id].must_equal Parameters.integer
      WhitelistsController.permitted_parameters_for(:foo)[:group_id].must_be_nil

      WhitelistsController.permitted_parameters_for(:bar)[:group_id].must_equal Parameters.integer
      WhitelistsController.permitted_parameters_for(:bar)[:ticket_id].must_be_nil
    end

    it 'allows merging' do
      WhitelistsController.permitted_parameters_for(:bar)[:nested].constraints.must_equal(
        "a" => Parameters.integer, "b" => Parameters.integer
      )
    end

    describe 'inheritance' do
      # rubocop:disable Lint/ConstantDefinitionInBlock
      class ChildController < WhitelistsController
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock

      before do
        WhitelistsController.permitted_parameters :create, first: Parameters.string
        WhitelistsController.log_invalid_parameters!
        ChildController.permitted_parameters :create, last: Parameters.string
      end

      it 'inherits from parent to child' do
        WhitelistsController.permitted_parameters_for(:create)[:first].
          must_be_instance_of StrongerParameters::StringConstraint
        ChildController.permitted_parameters_for(:create)[:first].
          must_be_instance_of StrongerParameters::StringConstraint
        assert_equal true, ChildController.log_unpermitted_parameters
      end

      it 'does not inherit from child to parent' do
        assert_nil WhitelistsController.permitted_parameters_for(:create)[:last]
        ChildController.permitted_parameters_for(:create)[:last].
          must_be_instance_of StrongerParameters::StringConstraint
      end
    end
  end

  describe '#permit_parameters' do
    def do_request
      get "/whitelists", params: parameters.merge(format: 'png')
    end

    let(:parameters) { {id: '4', authenticity_token: 'auth'} }

    before do
      WhitelistsController.permitted_parameters(
        :index,
        something: Parameters.anything,
        user: { name: Parameters.string }
      )
    end

    it 'does not filter default params' do
      do_request
      assert_response :success
      @controller.params.to_h.must_equal(
        "controller" => "whitelists",
        "action" => "index",
        "format" => "png",
        "authenticity_token" => "auth"
      )
    end

    it 'filters request.params' do
      do_request
      assert_response :success
      @controller.request.params.must_equal(
        "controller" => "whitelists",
        "action" => "index",
        "format" => "png",
        "authenticity_token" => "auth"
      )
    end

    it "can skip" do
      WhitelistsController.instance_variable_set(:@permit_parameters, nil)
      WhitelistsController.permitted_parameters :index, :skip
      do_request
      assert_response :success
      @controller.request.params.must_equal(
        "controller" => "whitelists",
        "action" => "index",
        "format" => "png",
        "authenticity_token" => "auth",
        "id" => "4"
      )
    end

    it "does not remove invalid because they only raise and do not filter" do
      parameters[:user] = {name: {so: "evil".dup}}
      do_request
      assert_response :success
      @controller.params.to_h["user"]["name"].must_equal("so" => "evil")
    end

    it 'raises when action is not configured' do
      get "/whitelists/1"
      assert_response :bad_request
    end

    it 'raises proper exception even if action is not defined (and not configured)' do
      get "/whitelists/1", params: {action: 'ops_not_here'}
      assert_response :bad_request
    end

    it 'overrides :skip' do
      WhitelistsController.permitted_parameters :index, :skip
      WhitelistsController.permitted_parameters :index, bar: Parameters.boolean
      get "/whitelists", params: {bar: true}
      assert_response :success
      @controller.params.to_h["bar"].must_equal(true)
    end

    describe "when raising on invalid params" do
      def do_request
        get "/whitelists", params: {user: {name: ["123".dup]}}
      end

      before { Parameters.action_on_invalid_parameters = :raise }

      it "raises" do
        do_request
        assert_response :bad_request
      end

      it "logs with log_invalid_parameters" do
        WhitelistsController.log_invalid_parameters!
        do_request
        assert_response :success
      end
    end

    describe "when raising on unpermitted params" do
      before { ActionController::Parameters.action_on_unpermitted_parameters = :raise }

      it "raises" do
        assert_raises(ActionController::UnpermittedParameters) { do_request }
      end

      it "raises with log_invalid_parameters on unpermitted" do
        WhitelistsController.log_invalid_parameters!
        assert_raises(ActionController::UnpermittedParameters) { do_request }
      end
    end

    describe 'headers' do
      before { Rails.configuration.stronger_parameters_violation_header = 'X-StrongerParameters-API-Warn' }
      after { Rails.configuration.stronger_parameters_violation_header = nil }

      it 'warns about filtered parms' do
        do_request
        @controller.response.headers['X-StrongerParameters-API-Warn'].must_equal(
          "Removed restricted keys [\"id\"] from parameters according to permitted list"
        )
      end

      it "warns about unfiltered parameters" do
        WhitelistsController.log_unpermitted_parameters = true
        do_request
        @controller.response.headers['X-StrongerParameters-API-Warn'].must_equal(
          "Found restricted keys [\"id\"] from parameters according to permitted list"
        )
      end

      it "does not blow up when header is not available" do
        Rails.configuration.expects(:respond_to?)
        Rails.configuration.expects(:stronger_parameters_violation_header).never
        do_request
        refute @controller.response.headers['X-StrongerParameters-API-Warn']
      end

      it 'warns about nil values' do
        # @controller.params[:id] = nil
        do_request
        @controller.response.headers['X-StrongerParameters-API-Warn'].must_equal(
          "Removed restricted keys [\"id\"] from parameters according to permitted list"
        )
      end

      it 'does not warn when not configured' do
        Rails.configuration.stronger_parameters_violation_header = nil
        do_request
        refute @controller.response.headers.key?('X-StrongerParameters-API-Warn')
      end
    end
  end
end
