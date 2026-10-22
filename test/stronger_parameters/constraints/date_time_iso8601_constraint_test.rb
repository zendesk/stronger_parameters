# frozen_string_literal: true

require_relative "../../test_helper"

SingleCov.covered!

describe "datetime_iso8601 parameter constraints" do
  [{}, {use_zone: false}, {use_zone: true}].each do |options|
    it "delegates to datetime with ISO8601 format and options #{options.inspect}" do
      expected = ActionController::Parameters.datetime(format: :iso8601, **options)
      expected_options = {format: :iso8601, use_zone: options.fetch(:use_zone, false)}
      factory = ->(**actual_options) do
        actual_options.must_equal expected_options
        expected
      end

      ActionController::Parameters.stub(:datetime, factory) do
        assert_same expected, ActionController::Parameters.datetime_iso8601(**options)
      end
    end
  end

  it "supports constructing the ISO8601 constraint directly" do
    constraint = StrongerParameters::DateTimeIso8601Constraint.new
    constraint.value("2018-04-12T08:53:18Z").must_equal DateTime.iso8601("2018-04-12T08:53:18Z")
    constraint.value("invalid").message.must_equal "must be an iso8601 datetime"
  end

  it "supports zone parsing and rejects existing DateTime values through the direct constructor" do
    with_env("TZ" => "Asia/Tokyo") do
      Time.use_zone("America/New_York") do
        [false, true].each do |use_zone|
          constraint = StrongerParameters::DateTimeIso8601Constraint.new(use_zone:)
          result = constraint.value("2018-04-12T08:53:18")
          if use_zone
            result.must_be_instance_of ActiveSupport::TimeWithZone
            result.time_zone.must_equal Time.zone
            result.utc_offset.must_equal(-4 * 3600)
          else
            result.must_be_instance_of DateTime
            result.offset.must_equal 0
          end
          value = DateTime.iso8601("2018-04-12T08:53:18+05:45")
          assert_instance_of StrongerParameters::InvalidValue, constraint.value(value)
        end
      end
    end
  end
end
