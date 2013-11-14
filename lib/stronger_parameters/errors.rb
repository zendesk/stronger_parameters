module StrongerParameters
  class InvalidParameter < StandardError
    attr_accessor :key, :value, :message

    def initialize(value, message)
      @value = value
      @message = message
      super(message)
    end

    def to_s
      if key.present?
        "found invalid value for #{key}. Value #{super}"
      else
        "found invalid value. Value #{super}"
      end
    end
  end
end
