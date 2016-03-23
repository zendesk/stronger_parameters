module StrongerParameters
  class InvalidValue
    attr_accessor :value, :message

    def initialize(value, message)
      @value = value
      @message = message
    end
  end

  class InvalidParameter < StandardError
    attr_accessor :key, :value

    def initialize(invalid_value, key)
      @value = invalid_value.value
      @key = key
      super("#{key} => #{invalid_value.message}")
    end
  end
end
