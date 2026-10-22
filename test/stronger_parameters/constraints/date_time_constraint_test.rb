# frozen_string_literal: true

require_relative "../../test_helper"

SingleCov.covered!

describe "datetime parameter constraints" do
  subject { ActionController::Parameters.datetime }

  def self.perform_basic_tests(strict: false)
    permits "2015-03-31T14:34:56Z", as: DateTime.iso8601("2015-03-31T14:34:56Z")
    permits "2018-04-12T08:53:18+05:45", as: DateTime.iso8601("2018-04-12T08:53:18+05:45")

    rejects []
    rejects 123
    rejects nil
    rejects "2015-03-32"  # Invalid day
    rejects "2015-00-15"  # Invalid month
    rejects "not a datetime"
    rejects ""

    rejects "2018-04-12T08:53:18Zxxx" if strict
  end

  # Stricter form of `permits` that also checks the returned value's class and day-based offset.
  def self.permits_datetime(value, as:)
    it "permits #{value.inspect} as #{as.inspect}" do
      result = params(value:).permit(value: subject)[:value]
      result.must_be_instance_of as.class
      result.must_equal as
      result.to_datetime.offset.must_equal as.to_datetime.offset
      result.time_zone.must_equal as.time_zone if as.is_a?(ActiveSupport::TimeWithZone)
    end
  end

  def self.perform_zone_tests(strict: false)
    perform_basic_tests(strict:)
    permits_datetime "2018-04-12T08:53:18.123456Z", as: Time.iso8601("2018-04-12T04:53:18.123456-04:00").in_time_zone("America/New_York")

    it "reads the zone when validating a reused constraint" do
      constraint = subject
      result = params(value: "2018-04-12T08:53:18Z").permit(value: constraint)[:value]
      result.utc_offset.must_equal(-4 * 3600)

      Time.use_zone("Asia/Kathmandu") do
        result = params(value: "2018-04-12T08:53:18Z").permit(value: constraint)[:value]
        result.must_equal Time.iso8601("2018-04-12T14:38:18+05:45").in_time_zone("Asia/Kathmandu")
        result.utc_offset.must_equal(5 * 3600 + 45 * 60)
      end
    end
  end

  it "rejects unsupported formats when constructing the constraint" do
    error = -> { ActionController::Parameters.datetime(format: :httpdate) }.must_raise ArgumentError
    error.message.must_equal "Unsupported datetime format: :httpdate"
  end

  describe "without format" do
    describe "without use_zone" do
      subject { ActionController::Parameters.datetime }

      perform_basic_tests

      permits DateTime.iso8601("2018-04-12T08:53:18Z")
      permits_datetime "2018-04-12T08:53:18", as: DateTime.iso8601("2018-04-12T08:53:18")
      permits_datetime "April 12, 2018 08:53:18", as: DateTime.iso8601("2018-04-12T08:53:18")
    end

    describe "with use_zone" do
      around do |test|
        with_env("TZ" => "Asia/Tokyo") do
          Time.use_zone(nil, &test)
        end
      end

      subject { ActionController::Parameters.datetime(use_zone: true) }

      perform_basic_tests

      permits DateTime.iso8601("2018-04-12T08:53:18+05:45")
      permits_datetime "April 12, 2018 08:53:18", as: DateTime.iso8601("2018-04-12T08:53:18Z")

      permits_datetime "2018-04-12T08:53:18Z", as: DateTime.iso8601("2018-04-12T08:53:18Z")
      permits_datetime "2018-04-12T08:53:18", as: DateTime.iso8601("2018-04-12T08:53:18Z")

      describe "when Time.use_zone is configured" do
        around do |test|
          Time.use_zone("America/New_York", &test)
        end

        perform_zone_tests

        permits_datetime "2018-04-12T08:53:18Z", as: Time.iso8601("2018-04-12T04:53:18-04:00").in_time_zone("America/New_York")
        permits_datetime "2018-04-12T08:53:18", as: Time.iso8601("2018-04-12T08:53:18-04:00").in_time_zone("America/New_York")
      end
    end
  end

  describe "with iso8601" do
    describe "without use_zone" do
      subject { ActionController::Parameters.datetime(format: :iso8601) }

      perform_basic_tests(strict: true)

      rejects DateTime.iso8601("2018-04-12T08:53:18+05:45")

      permits_datetime "2018-04-12", as: DateTime.iso8601("2018-04-12")
      permits_datetime "20180412T085318Z", as: DateTime.iso8601("2018-04-12T08:53:18Z")
      permits_datetime "2018-W15-4", as: DateTime.iso8601("2018-04-12")
      permits_datetime "2018-102", as: DateTime.iso8601("2018-04-12")
      permits_datetime "2018-04-12T08:53:18Z", as: DateTime.iso8601("2018-04-12T08:53:18Z")
      permits_datetime "2018-04-12T08:53:18", as: DateTime.iso8601("2018-04-12T08:53:18")

      describe "when Time.use_zone is configured" do
        around do |test|
          Time.use_zone("America/New_York", &test)
        end

        permits_datetime "2018-04-12T08:53:18", as: DateTime.iso8601("2018-04-12T08:53:18Z")
      end
    end

    describe "with use_zone" do
      subject { ActionController::Parameters.datetime(format: :iso8601, use_zone: true) }

      around do |test|
        with_env("TZ" => "Asia/Tokyo") do
          Time.use_zone(nil, &test)
        end
      end

      perform_basic_tests(strict: true)

      rejects DateTime.iso8601("2018-04-12T08:53:18Z")
      rejects "April 12, 2018 08:53:18"

      permits_datetime "2018-04-12", as: DateTime.iso8601("2018-04-12")
      permits_datetime "20180412T085318Z", as: DateTime.iso8601("2018-04-12T08:53:18Z")
      permits_datetime "2018-W15-4", as: DateTime.iso8601("2018-04-12")
      permits_datetime "2018-102", as: DateTime.iso8601("2018-04-12")
      permits_datetime "2018-04-12T08:53:18Z", as: DateTime.iso8601("2018-04-12T08:53:18Z")
      permits_datetime "2018-04-12T08:53:18", as: DateTime.iso8601("2018-04-12T08:53:18Z")

      describe "when Time.use_zone is configured" do
        around do |test|
          Time.use_zone("America/New_York", &test)
        end

        perform_zone_tests(strict: true)

        rejects DateTime.iso8601("2018-04-12T08:53:18+05:45")
        rejects "April 12, 2018 08:53:18"
        rejects "2018-04-12T08:53:18Zxxx"
        rejects "2018-W15-4"

        permits_datetime "2018-04-12", as: Time.iso8601("2018-04-12T04:00:00Z").in_time_zone("America/New_York")
        permits_datetime "2018-04-12T08:53:18Z", as: Time.iso8601("2018-04-12T08:53:18Z").in_time_zone("America/New_York")
        permits_datetime "2018-04-12T08:53:18", as: Time.iso8601("2018-04-12T08:53:18-04:00").in_time_zone("America/New_York")
        permits_datetime "2018-04-12T08:53:18+05:45", as: Time.iso8601("2018-04-12T08:53:18+05:45").in_time_zone("America/New_York")
        permits_datetime "2018-04-12T08:53:18-07:00", as: Time.iso8601("2018-04-12T08:53:18-07:00").in_time_zone("America/New_York")
        permits_datetime "2018-04-12T08:53:18.123456", as: Time.iso8601("2018-04-12T08:53:18.123456-04:00").in_time_zone("America/New_York")
        permits_datetime "2018-01-12T08:53:18", as: Time.iso8601("2018-01-12T08:53:18-05:00").in_time_zone("America/New_York")
        permits_datetime "20180412T085318Z", as: Time.iso8601("2018-04-12T08:53:18Z").in_time_zone("America/New_York")
        permits_datetime "2018-102", as: Time.iso8601("2018-04-12T00:00:00-04:00").in_time_zone("America/New_York")
      end
    end
  end

  describe "with rfc3339" do
    describe "without use_zone" do
      subject { ActionController::Parameters.datetime(format: :rfc3339) }

      perform_basic_tests(strict: true)

      rejects DateTime.iso8601("2018-04-12T08:53:18+05:45")
      rejects "2018-04-12T08:53:18" # No timezone
      rejects "2018-04-12" # Date only
    end

    describe "with use_zone" do
      subject { ActionController::Parameters.datetime(format: :rfc3339, use_zone: true) }

      around do |test|
        with_env("TZ" => "Asia/Tokyo") do
          Time.use_zone(nil, &test)
        end
      end

      perform_basic_tests(strict: true)

      rejects DateTime.iso8601("2018-04-12T08:53:18+05:45")
      rejects "2018-04-12T08:53:18" # No timezone
      rejects "2018-04-12" # Date only
      rejects "20180412T085318Z" # Missing separators
      rejects "2018-102"

      permits_datetime "2018-04-12T08:53:18Z", as: DateTime.iso8601("2018-04-12T08:53:18Z")

      describe "when Time.use_zone is configured" do
        around do |test|
          Time.use_zone("America/New_York", &test)
        end

        perform_zone_tests(strict: true)

        permits_datetime "2018-04-12T08:53:18Z", as: Time.iso8601("2018-04-12T08:53:18Z").in_time_zone("America/New_York")
      end
    end
  end
end
