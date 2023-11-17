# frozen_string_literal: true

require "stronger_parameters/constraint"

module StrongerParameters
  class UlidConstraint < Constraint
    # https://www.crockford.com/base32.html
    INVALID_CHAR_REGEX = /[ilou]|[^a-z0-9]/i.freeze
    ULID_LENGTH = 26

    def value(v)
      return invalid_value(v) unless v.is_a?(String)
      return invalid_value(v) unless v.length == ULID_LENGTH
      return invalid_value(v) if v =~ INVALID_CHAR_REGEX

      v
    end

    private

    def invalid_value(v)
      StrongerParameters::InvalidValue.new(v, "must be a ULID")
    end
  end
end
