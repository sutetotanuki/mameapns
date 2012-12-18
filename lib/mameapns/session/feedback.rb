module Mameapns
  class Session
    class Feedback < Session
      
      TAPLE_BYTES = 38
      POLL = 60
      
      def start_session
        while running?
          connect
          
          while tuple = read(TAPLE_BYTES)
            timestamp, _, device_token = tuple.unpack('N1n1H*')
            handler_error(nil, DeviceNotExist.new(timestamp, device_token))
          end

          close
          
          interruptible_sleep.wait(POLL)
        end
      end
    end
  end
end
