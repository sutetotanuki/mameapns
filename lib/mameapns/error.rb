module Mameapns
  class Error < StandardError; end

  # Connection error
  # never succeed to send notificaiont while
  # resolve under problems.
  class ConnectionError < Error; end
  class SSLError < ConnectionError; end

  # Delivery error
  class DeliveryError < Error
    attr_accessor :code, :description
    
    def initialize(code, description)
      @code, @description = code, description
      super(description)
    end
  end
  class DisconnectionError < Error; end
end
