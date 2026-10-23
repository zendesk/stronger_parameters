# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "../../support/date_time_format_tests"

SingleCov.covered!

describe "datetime parameter constraints" do
  extend DateTimeFormatTests

  it "rejects unsupported formats when constructing the constraint" do
    error = -> { ActionController::Parameters.datetime(format: :httpdate) }.must_raise ArgumentError
    error.message.must_equal "Unsupported datetime format: :httpdate"
  end

  [nil, :iso8601, :rfc3339].each do |format|
    describe "format #{format.inspect}" do
      subject { ActionController::Parameters.datetime(format:) }

      validates_format_matrix(:datetime, format:)

      it "passes through existing DateTime values unchanged" do
        value = DateTime.iso8601("2018-04-12T08:53:18.123456+05:45")
        result = params(value:).permit(value: subject)[:value]
        assert_same value, result
      end

      it "reports the selected format for invalid values" do
        expected = format ? "must be an #{format} datetime" : "must be a datetime"
        subject.value("invalid").message.must_equal expected
      end
    end
  end
end
