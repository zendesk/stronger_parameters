# frozen_string_literal: true

module StrongerParameters
  class InvalidValue
    attr_reader :value, :message

    def initialize(value, message)
      @value = value
      @message = message
    end
  end

  class InvalidParameter < StandardError
    attr_reader :key, :value

    def initialize(invalid_value, key)
      @value = invalid_value.value
      @key = key
      super("Invalid parameter: #{@key} #{invalid_value.message}")
    end
  end
end
