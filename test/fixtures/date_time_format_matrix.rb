# frozen_string_literal: true

require "date"
require "time"

# Input value => format => constraint name => expected value.
# nil at any level means rejection for every case below that level.
# A nil format selects permissive parsing. Time.local uses the process timezone
# when this fixture is loaded; DateTime defaults to UTC for timezone-less input.
DATE_TIME_FORMAT_MATRIX = {
  [] => nil,
  123 => nil,
  nil => nil,
  "" => nil,
  "invalid" => nil,
  "not a date" => nil,
  "not a datetime" => nil,
  "not a time" => nil,
  "2015-00-15" => nil,
  "2015-03-32" => nil,
  "2015-03-21" => {
    nil => {
      date: Date.new(2015, 3, 21),
      datetime: DateTime.new(2015, 3, 21),
      time: Time.local(2015, 3, 21, 0, 0, 0)
    },
    :iso8601 => {
      date: Date.new(2015, 3, 21),
      datetime: DateTime.new(2015, 3, 21),
      time: nil
    },
    :rfc3339 => nil
  },
  "2015-03-31" => {
    nil => {
      date: Date.new(2015, 3, 31),
      datetime: DateTime.new(2015, 3, 31),
      time: Time.local(2015, 3, 31, 0, 0, 0)
    },
    :iso8601 => {
      date: Date.new(2015, 3, 31),
      datetime: DateTime.new(2015, 3, 31),
      time: nil
    },
    :rfc3339 => nil
  },
  "2015-03-31T14:34:56Z" => {
    nil => {
      date: Date.new(2015, 3, 31),
      datetime: DateTime.new(2015, 3, 31, 14, 34, 56),
      time: Time.utc(2015, 3, 31, 14, 34, 56)
    },
    :iso8601 => {
      date: Date.new(2015, 3, 31),
      datetime: DateTime.new(2015, 3, 31, 14, 34, 56),
      time: Time.utc(2015, 3, 31, 14, 34, 56)
    },
    :rfc3339 => {
      date: Date.new(2015, 3, 31),
      datetime: DateTime.new(2015, 3, 31, 14, 34, 56),
      time: Time.utc(2015, 3, 31, 14, 34, 56)
    }
  },
  "2015-03-31T14:34:56Zxxx" => {
    nil => {
      date: Date.new(2015, 3, 31),
      datetime: DateTime.new(2015, 3, 31, 14, 34, 56),
      time: Time.local(2015, 3, 31, 14, 34, 56)
    },
    :iso8601 => nil,
    :rfc3339 => nil
  },
  "2018-04-12" => {
    nil => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12),
      time: Time.local(2018, 4, 12, 0, 0, 0)
    },
    :iso8601 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12),
      time: nil
    },
    :rfc3339 => nil
  },
  "2018-04-12T08:53:18" => {
    nil => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, 18),
      time: Time.local(2018, 4, 12, 8, 53, 18)
    },
    :iso8601 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, 18),
      time: Time.local(2018, 4, 12, 8, 53, 18)
    },
    :rfc3339 => nil
  },
  "2018-04-12T08:53:18+00:00" => {
    nil => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, 18),
      time: Time.utc(2018, 4, 12, 8, 53, 18)
    },
    :iso8601 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, 18),
      time: Time.utc(2018, 4, 12, 8, 53, 18)
    },
    :rfc3339 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, 18),
      time: Time.utc(2018, 4, 12, 8, 53, 18)
    }
  },
  "2018-04-12T08:53:18.123456+05:45" => {
    nil => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, Rational(283179, 15625), Rational(23, 96)),
      time: Time.new(2018, 4, 12, 8, 53, Rational(283179, 15625), 20700)
    },
    :iso8601 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, Rational(283179, 15625), Rational(23, 96)),
      time: Time.new(2018, 4, 12, 8, 53, Rational(283179, 15625), 20700)
    },
    :rfc3339 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, Rational(283179, 15625), Rational(23, 96)),
      time: Time.new(2018, 4, 12, 8, 53, Rational(283179, 15625), 20700)
    }
  },
  "2018-04-12T08:53:18Z" => {
    nil => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, 18),
      time: Time.utc(2018, 4, 12, 8, 53, 18)
    },
    :iso8601 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, 18),
      time: Time.utc(2018, 4, 12, 8, 53, 18)
    },
    :rfc3339 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, 18),
      time: Time.utc(2018, 4, 12, 8, 53, 18)
    }
  },
  "2018-04-12T23:53:18.123456-07:00" => {
    nil => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 23, 53, Rational(283179, 15625), Rational(-7, 24)),
      time: Time.new(2018, 4, 12, 23, 53, Rational(283179, 15625), -25200)
    },
    :iso8601 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 23, 53, Rational(283179, 15625), Rational(-7, 24)),
      time: Time.new(2018, 4, 12, 23, 53, Rational(283179, 15625), -25200)
    },
    :rfc3339 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 23, 53, Rational(283179, 15625), Rational(-7, 24)),
      time: Time.new(2018, 4, 12, 23, 53, Rational(283179, 15625), -25200)
    }
  },
  "2018-102" => {
    nil => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12),
      time: Time.local(2018, 4, 12, 0, 0, 0)
    },
    :iso8601 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12),
      time: nil
    },
    :rfc3339 => nil
  },
  "2018-W15-4" => {
    nil => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12),
      time: nil
    },
    :iso8601 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12),
      time: nil
    },
    :rfc3339 => nil
  },
  "20180412T085318Z" => {
    nil => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, 18),
      time: Time.utc(2018, 4, 12, 8, 53, 18)
    },
    :iso8601 => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, 18),
      time: nil
    },
    :rfc3339 => nil
  },
  "April 12, 2018 08:53:18" => {
    nil => {
      date: Date.new(2018, 4, 12),
      datetime: DateTime.new(2018, 4, 12, 8, 53, 18),
      time: Time.local(2018, 4, 12, 8, 53, 18)
    },
    :iso8601 => nil,
    :rfc3339 => nil
  }
}.freeze
