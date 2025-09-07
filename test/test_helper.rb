# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require "bundler/setup"

require "single_cov"
SingleCov.setup :minitest

require "maxitest/global_must"
require "maxitest/autorun"
require "rails"
require "action_controller"
require "rails/generators"

class FakeApplication < Rails::Application; end

Rails.application = FakeApplication
Rails.configuration.action_controller = ActiveSupport::OrderedOptions.new
Rails.configuration.secret_key_base = "secret_key_base"
Rails.logger = Logger.new("/dev/null")

ActiveSupport.test_order = :random if ActiveSupport.respond_to?(:test_order=)

require "action_pack"
require "stronger_parameters"

# Add spec DSL to the TestCase class
# This is all we needed from minitest-rails
ActiveSupport.on_load(:active_support_test_case) { extend Minitest::Spec::DSL }

# Use ActionController::TestCase for Controllers
Minitest::Spec::DSL::TYPES.unshift [/Controller$/, ActionController::TestCase]

class Minitest::Test
  def params(hash)
    ActionController::Parameters.new(hash)
  end

  def assert_rejects(key, &block)
    err = block.must_raise StrongerParameters::InvalidParameter
    err.key.must_equal key.to_s
  end

  def capture_log
    io = StringIO.new
    old = Rails.logger
    Rails.logger = Logger.new(io)
    yield
    io.string
  ensure
    Rails.logger = old
  end

  def self.permits(value, as: value)
    type_casted = as

    it "permits #{value.inspect} as #{type_casted.inspect}" do
      permitted = params(value: value).permit(value: subject)
      permitted = permitted.to_h
      if type_casted.nil?
        permitted[:value].must_be_nil
      else
        permitted[:value].must_equal type_casted
      end
    end
  end

  def self.rejects(value, key: :value)
    it "rejects #{value.inspect}" do
      assert_rejects(key) { params(value: value).permit(value: subject) }
    end
  end
end
