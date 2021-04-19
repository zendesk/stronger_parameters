# frozen_string_literal: true
require_relative 'test_helper'

SingleCov.covered! uncovered: (ActiveSupport::VERSION::MAJOR < 5 ? 1 : 0) # uncovered branches for rails version check
