# frozen_string_literal: true

require_relative "../fixtures/date_time_format_matrix"

module DateTimeFormatTests
  def validates_format_matrix(constraint, format:)
    DATE_TIME_FORMAT_MATRIX.each do |input, formats|
      expected = formats&.fetch(format)&.fetch(constraint)

      if expected.nil?
        rejects input
      else
        it "permits #{input.inspect} as #{expected.inspect}" do
          result = params(value: input).permit(value: subject)[:value]
          result.must_be_instance_of expected.class
          result.must_equal expected
          if expected.is_a?(DateTime)
            result.offset.must_equal expected.offset
          elsif expected.is_a?(Time)
            result.utc_offset.must_equal expected.utc_offset
          end
        end
      end
    end
  end
end
