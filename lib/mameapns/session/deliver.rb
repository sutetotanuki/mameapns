# -*- coding: utf-8 -*-
module Mameapns
  class Session
    class Deliver < Session
      SELECT_TIMEOUT = 0.5
      ERROR_TUPLE_BYTES = 6
      
      APN_ERRORS = {
        1 => "Processing error",
        2 => "Missing device token",
        3 => "Missing topic",
        4 => "Missing payload",
        5 => "Missing token size",
        6 => "Missing topic size",
        7 => "Missing payload size",
        8 => "Invalid token",
        255 => "None (unknown error)"
      }
      
      def start_session
        connect
        
        while notification = queue.pop
          deliver(notification)
        end

        close
      end
      
      def deliver(notification)
        write(notification.to_binary)
          
        check_for_error(notification)
          
        handle_sent(notification)
      end
      
      def check_for_error(notification)
        if select(SELECT_TIMEOUT)
          if tuple = read(ERROR_TUPLE_BYTES)
            cmd, code, notification_id = tuple.unpack("ccN")
            
            description = APN_ERRORS[code.to_i] || "Unknown error."
            handle_error(notification, Mameapns::DeliveryError.new(code, description))
          else
            handle_error(notification, Mameapns::DisconnectionError.new)
          end
          
          begin
            # エラーをうけとったらreconnectする。
            reconnect
          end
        end
      end
    end
  end
end
