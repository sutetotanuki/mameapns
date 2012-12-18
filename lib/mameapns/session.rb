module Mameapns
  class Session
    attr_accessor :connection, :ssl_cert, :ssl_cert_key, :ssl_cert_pass, :host, :port, :queue, :interruptible_sleep

    Dir["#{File.expand_path("../", __FILE__)}/session/*.rb"].each do |file|
      require file
    end
    
    def initialize(options)
      options.each do |k, v|
        setter_name = "#{k}="
        self.__send__(setter_name, v) if respond_to?(setter_name)
      end

      @connection ||= Connection.new(host, port,
        ssl_cert: ssl_cert,
        ssl_cert_key: ssl_cert_key,
        ssl_cert_pass: ssl_cert_pass,
        )
      
      @on_exception = nil
      @on_error = nil
      
      @thread = nil
      @queue = Queue.new
      @running = false
      @interruptible_sleep = InterruptibleSleep.new
    end

    def start
      # connect to apns.
      @running = true
      
      @thread = Thread.start do
        begin
          start_session
        rescue => e
          @on_exception.call(e) if @on_exception
          retry
        end
      end
    end

    def start_session
      # expect to implement by sub class
    end

    def end_session
      # expect to implement by sub class
    end

    def handle_error(notification, err)
      @on_error.call(notification, err) if @on_error
    end

    def handle_sent(notification)
      @on_sent.call(notification) if @on_sent
    end

    def stop
      @queue << nil
      @running = false
      @interruptible_sleep.interrupt
      sleep 1 # FIXME: magic number
    end

    def wait_stop
      @thread.join
    end

    def running?
      !!@running
    end

    def push(data)
      @queue << data
    end

    def select(wait_time)
      @connection.select(wait_time)
    end

    def read(size)
      @connection.read(size)
    end

    def write(data)
      @connection.write(data)
    end

    def connect
      @connection.connect
    end

    def close
      @connection.close
    end
    
    def reconnect
      @connection.reconnect
    end

    def on_exception(&block)
      @on_exception = block
    end

    def on_error(&block)
      @on_error = block
    end

    def on_sent(&block)
      @on_sent = block
    end
  end
end
