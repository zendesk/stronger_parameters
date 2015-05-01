require 'stronger_parameters/constraints'

module StrongerParameters
  class DateTimeConstraint < Constraint
    def value(v)
      return v if v.is_a?(DateTime)

      begin
        DateTime.parse v
      rescue ArgumentError
        StrongerParameters::InvalidValue.new(v, "must be a date")
      end
    end
  end
end
