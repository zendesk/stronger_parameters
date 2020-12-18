# frozen_string_literal: true
ENV["RAILS_ENV"] = "test"

require 'bundler/setup'

require 'single_cov'
SingleCov.setup :minitest

require 'rails'
require 'rails/generators'

require 'minitest/autorun'
require 'minitest/rg'
require 'minitest/around'
require 'minitest/rails'
require 'mocha/setup'
require 'pry'

require 'stronger_parameters'

class FakeApplication < Rails::Application
  config.action_dispatch.show_exceptions = false
  config.logger = Logger.new("/dev/null")
end

FakeApplication.initialize!

FakeApplication.routes.draw do
  resources :whitelists
  resources :books
end

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

  def self.permits(value, options = {})
    type_casted = options.fetch(:as, value)

    it "permits #{value.inspect} as #{type_casted.inspect}" do
      permitted = params(value: value).permit(value: subject)
      permitted = permitted.to_h if Rails::VERSION::MAJOR >= 5
      if type_casted.nil?
        permitted[:value].must_be_nil
      else
        permitted[:value].must_equal type_casted
      end
    end
  end

  def self.rejects(value, options = {})
    key = options.fetch(:key, :value)

    it "rejects #{value.inspect}" do
      assert_rejects(key) { params(value: value).permit(value: subject) }
    end
  end
end
