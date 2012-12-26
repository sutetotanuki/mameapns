require 'openssl'
require 'socket'

module Mameapns
  
  class Connection
    attr_accessor :ssl_cert, :ssl_cert_key, :ssl_cert_pass, :host, :port, :last_write

    IDLE_PERIOD = 1800

    def initialize(host, port, options={})
      self.host = host
      self.port = port

      options.each do |k, v|
        setter_name = "#{k}="
        self.__send__(setter_name, v) if respond_to?(setter_name)
      end

      written
    end

    def connect
      setup_ssl_context
      @tcp_socket, @ssl_socket = connect_socket
    end

    def close
      begin
        @tcp_socket.close
        @ssl_socket.close
      rescue IOError
      end
    end

    def read(bytesize)
      @ssl_socket.read(bytesize)
    end

    def select(timeout)
      IO.select([@ssl_socket], nil, nil, timeout)
    end

    def reconnect
      close
      @tcp_socket, @ssl_socket = connect_socket
    end

    def write(data)
      reconnect if idle_period_exceeded?
      
      retry_count = 0

      begin
        write_data(data)
      rescue Errno::EPIPE, Errno::ETIMEOUT, OpenSSL::SSL::SSLError => e
        retry_count += 1
        
        if retry_count <= 3
          reconnect
          sleep 1
          retry
        else
          raise ConnectionError, "Attempt to reconnect but failed"
        end
      end
    end

    def write_data(data)
      @ssl_socket.write(data)
      @ssl_socket.flush
      written
    end

    def idle_period_exceeded?
      Time.now - last_write > IDLE_PERIOD
    end

    def written
      self.last_write = Time.now
    end
    
    def setup_ssl_context
      begin
        @ssl_context = OpenSSL::SSL::SSLContext.new
        @ssl_context.key = OpenSSL::PKey::RSA.new(ssl_cert_key, ssl_cert_pass)
        @ssl_context.cert = OpenSSL::X509::Certificate.new(ssl_cert)
        @ssl_context
      rescue OpenSSL::PKey::RSAError => e
        raise SSLError, "Neither PUB key nor PRIV key:: nested asn1 error"
      end
    end

    def connect_socket
      begin
        tcp_socket = TCPSocket.new(host, port)
        tcp_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, 1)
        tcp_socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        ssl_socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, @ssl_context)
        ssl_socket.sync = true
        ssl_socket.connect
        [tcp_socket, ssl_socket]
      rescue OpenSSL::SSL::SSLError => e
        raise SSLError, e
      rescue SocketError => e
        raise ConnectionError, e
      end
    end
  end
end
