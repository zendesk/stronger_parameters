# frozen_string_literal: true
require 'stronger_parameters/constraint'

module StrongerParameters
  class HexConstraint < Constraint
    def value(v)
      return v if v.is_a?(String) && v.match?(/\A[a-f0-9]+\z/i)

      InvalidValue.new(v, 'must be a hexadecimal string')
    end
  end
end
