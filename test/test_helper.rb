ENV["RAILS_ENV"] = "test"

require 'bundler/setup'
require 'minitest/autorun'
require 'rails'
require 'action_controller'
require 'rails/test_help'

class FakeApplication < Rails::Application; end

Rails.application = FakeApplication
Rails.configuration.action_controller = ActiveSupport::OrderedOptions.new
Rails.configuration.secret_key_base = 'secret_key_base'

require 'action_pack'
require 'strong_parameters' if ActionPack::VERSION::MAJOR == 3

module ActionController
  SharedTestRoutes = ActionDispatch::Routing::RouteSet.new
  SharedTestRoutes.draw do
    get ':controller(/:action)'
    post ':controller(/:action)'
    put ':controller(/:action)'
    delete ':controller(/:action)'
  end

  class Base
    include ActionController::Testing
    include SharedTestRoutes.url_helpers

    rescue_from(ActionController::ParameterMissing) do |e|
      render :text => "Required parameter missing: #{e.param}", :status => :bad_request
    end
  end

  class ActionController::TestCase
    setup do
      @routes = SharedTestRoutes
    end
  end
end

require 'stronger_parameters'
require 'minitest/rails'
require 'minitest/autorun'

ActionController::Parameters.action_on_invalid_parameters = :raise

class MiniTest::Spec
  def params(hash)
    ActionController::Parameters.new(hash)
  end

  def assert_rejects(key, &block)
    err = block.must_raise StrongerParameters::InvalidParameter
    err.key.must_equal key.to_s
  end

  def self.permits(value, options = {})
    type_casted = options.fetch(:as, value)

    it "permits #{value.inspect} as #{type_casted.inspect}" do
      permitted = params(:value => value).permit(:value => subject)
      permitted[:value].must_equal type_casted
    end
  end

  def self.rejects(value, options = {})
    key = options.fetch(:key, :value)

    it "rejects #{value.inspect}" do
      assert_rejects(key) { params(:value => value).permit(:value => subject) }
    end
  end
end
