# frozen_string_literal: true

require_relative "../../test_helper"

SingleCov.covered!

describe "time parameter constraints" do
  subject { ActionController::Parameters.time }

  def self.perform_basic_tests(strict: false)
    permits "2015-03-31T14:34:56Z", as: Time.iso8601("2015-03-31T14:34:56Z")
    permits "2018-04-12T08:53:18+05:45", as: Time.iso8601("2018-04-12T08:53:18+05:45")

    rejects []
    rejects 123
    rejects nil
    rejects "2015-03-32"  # Invalid day
    rejects "2015-00-15"  # Invalid month
    rejects "not a time"

    rejects "2018-04-12T08:53:18Zxxx" if strict
  end

  # Stricter form of `permits` that also checks the returned value's class and UTC offset.
  def self.permits_time(value, as:)
    it "permits #{value.inspect} as #{as.inspect}" do
      result = params(value:).permit(value: subject)[:value]
      result.must_be_instance_of as.class
      result.must_equal as
      result.utc_offset.must_equal as.utc_offset
    end
  end

  it "rejects unsupported formats when constructing the constraint" do
    error = -> { ActionController::Parameters.time(format: :httpdate) }.must_raise ArgumentError
    error.message.must_equal "Unsupported time format: :httpdate"
  end

  describe "without format" do
    describe "without use_zone" do
      subject { ActionController::Parameters.time }

      perform_basic_tests
      permits Time.iso8601("2018-04-12T08:53:18Z")
      permits_time "2018-04-12T08:53:18", as: Time.iso8601("2018-04-12T08:53:18")
      permits_time "April 12, 2018 08:53:18", as: Time.iso8601("2018-04-12T08:53:18")
    end

    describe "with use_zone" do
      around do |test|
        with_env("TZ" => "Asia/Tokyo", &test)
      end

      subject { ActionController::Parameters.time(use_zone: true) }

      perform_basic_tests
      permits Time.iso8601("2018-04-12T08:53:18+05:45")
      permits_time "April 12, 2018 08:53:18", as: Time.iso8601("2018-04-12T08:53:18+09:00")

      permits_time "2018-04-12T08:53:18Z", as: Time.iso8601("2018-04-12T08:53:18Z")
      permits_time "2018-04-12T08:53:18", as: Time.iso8601("2018-04-12T08:53:18+09:00")

      describe "when Time.use_zone is configured" do
        around do |test|
          Time.use_zone("America/New_York", &test)
        end

        permits_time "2018-04-12T08:53:18Z", as: Time.iso8601("2018-04-12T04:53:18-04:00").in_time_zone("America/New_York")
        permits_time "2018-04-12T08:53:18", as: Time.iso8601("2018-04-12T08:53:18-04:00").in_time_zone("America/New_York")
      end
    end
  end

  describe "with iso8601" do
    describe "without use_zone" do
      subject { ActionController::Parameters.time(format: :iso8601) }

      perform_basic_tests(strict: true)

      rejects Time.iso8601("2018-04-12T08:53:18+05:45")
      rejects "2018-04-12" # Date only
      rejects "20180412T085318Z" # Missing separators
      rejects "2018-W15-4"
      rejects "2018-102"

      permits_time "2018-04-12T08:53:18+00:00", as: Time.iso8601("2018-04-12T08:53:18+00:00")
      permits_time "2018-04-12T08:53:18", as: Time.iso8601("2018-04-12T08:53:18")

      it "ignores the configured zone by default" do
        with_env("TZ" => "Asia/Tokyo") do
          Time.use_zone("Asia/Singapore") do
            result = params(value: "2018-04-12T08:53:18").permit(value: subject)[:value]
            result.must_be_instance_of Time
            result.must_equal Time.iso8601("2018-04-12T08:53:18+09:00")
            result.utc_offset.must_equal(9 * 3600)
          end
        end
      end
    end

    describe "with use_zone" do
      subject { ActionController::Parameters.time(format: :iso8601, use_zone: true) }

      around do |test|
        with_env("TZ" => "Asia/Tokyo") do
          Time.use_zone(nil, &test)
        end
      end

      perform_basic_tests(strict: true)

      rejects Time.iso8601("2018-04-12T08:53:18Z")
      rejects "April 12, 2018 08:53:18"
      rejects "2018-04-12" # Date only (without Time.zone)

      permits_time "2018-04-12T08:53:18Z", as: Time.iso8601("2018-04-12T08:53:18Z")
      permits_time "2018-04-12T08:53:18", as: Time.iso8601("2018-04-12T08:53:18+09:00")

      describe "when Time.use_zone is configured" do
        around do |test|
          Time.use_zone("America/New_York", &test)
        end

        perform_basic_tests(strict: true)

        rejects Time.iso8601("2018-04-12T08:53:18+05:45")
        rejects "April 12, 2018 08:53:18"
        rejects "2018-04-12T08:53:18Zxxx"
        rejects "2018-W15-4"

        permits_time "2018-04-12", as: Time.iso8601("2018-04-12T04:00:00Z").in_time_zone("America/New_York")
        permits_time "2018-04-12T08:53:18Z", as: Time.iso8601("2018-04-12T08:53:18Z").in_time_zone("America/New_York")
        permits_time "2018-04-12T08:53:18", as: Time.iso8601("2018-04-12T08:53:18-04:00").in_time_zone("America/New_York")
        permits_time "2018-04-12T08:53:18+05:45", as: Time.iso8601("2018-04-12T08:53:18+05:45").in_time_zone("America/New_York")
        permits_time "2018-04-12T08:53:18-07:00", as: Time.iso8601("2018-04-12T08:53:18-07:00").in_time_zone("America/New_York")
        permits_time "2018-04-12T08:53:18.123456", as: Time.iso8601("2018-04-12T08:53:18.123456-04:00").in_time_zone("America/New_York")
        permits_time "2018-01-12T08:53:18", as: Time.iso8601("2018-01-12T08:53:18-05:00").in_time_zone("America/New_York")
        permits_time "20180412T085318Z", as: Time.iso8601("2018-04-12T08:53:18Z").in_time_zone("America/New_York")
        permits_time "2018-102", as: Time.iso8601("2018-04-12T00:00:00-04:00").in_time_zone("America/New_York")
      end
    end
  end

  describe "with rfc3339" do
    describe "without use_zone" do
      subject { ActionController::Parameters.time(format: :rfc3339) }

      perform_basic_tests(strict: true)

      rejects Time.iso8601("2018-04-12T08:53:18+05:45")
      rejects "2018-04-12T08:53:18" # No timezone
      rejects "2018-04-12" # Date only
    end

    describe "with use_zone" do
      subject { ActionController::Parameters.time(format: :rfc3339, use_zone: true) }

      around do |test|
        with_env("TZ" => "Asia/Tokyo") do
          Time.use_zone(nil, &test)
        end
      end

      perform_basic_tests(strict: true)

      rejects Time.iso8601("2018-04-12T08:53:18+05:45")
      rejects "2018-04-12T08:53:18" # No timezone
      rejects "2018-04-12" # Date only
      rejects "20180412T085318Z" # Missing separators
      rejects "2018-102"

      permits_time "2018-04-12T08:53:18Z", as: Time.iso8601("2018-04-12T08:53:18Z")

      describe "when Time.use_zone is configured" do
        around do |test|
          Time.use_zone("America/New_York", &test)
        end

        permits_time "2018-04-12T08:53:18Z", as: Time.iso8601("2018-04-12T08:53:18Z").in_time_zone("America/New_York")
      end
    end
  end
end
