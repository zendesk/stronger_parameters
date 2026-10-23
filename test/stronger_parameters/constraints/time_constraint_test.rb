# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "../../support/date_time_format_tests"

SingleCov.covered!

describe "time parameter constraints" do
  extend DateTimeFormatTests

  it "rejects unsupported formats when constructing the constraint" do
    error = -> { ActionController::Parameters.time(format: :httpdate) }.must_raise ArgumentError
    error.message.must_equal "Unsupported time format: :httpdate"
  end

  [nil, :iso8601, :rfc3339].each do |format|
    describe "format #{format.inspect}" do
      subject { ActionController::Parameters.time(format:) }

      validates_format_matrix(:time, format:)

      it "passes through existing Time values unchanged" do
        value = Time.iso8601("2018-04-12T08:53:18.123456+05:45")
        result = params(value:).permit(value: subject)[:value]
        assert_same value, result
      end

      it "reports the selected format for invalid values" do
        expected = format ? "must be an #{format} time" : "must be a time"
        subject.value("invalid").message.must_equal expected
      end
    end
  end
end
