module Mameapns
  class Application
    include Options

    options :host
    options :port, default: 2195
    options :feedback_host
    options :feedback_port, default: 2196
    options :ssl_cert
    options :ssl_cert_key
    options :ssl_cert_pass
    options :develop, default: false

    def host
      @host ||= if develop
                  "gateway.sandbox.push.apple.com"
                else
                  "gateway.push.apple.com"
                end
    end

    def feedback_host
      @feedback_host ||= if develop
                  "feedback.sandbox.push.apple.com"
                else
                  "feedback.push.apple.com"
                end
    end
    
    def start
      @deliver_session = Session::Deliver.new(
        ssl_cert:      ssl_cert,
        ssl_cert_key:  ssl_cert_key,
        ssl_cert_pass: ssl_cert_pass,
        host:          host,
        port:          port
        )

      @feedback_session = Session::Feedback.new(
        ssl_cert:      ssl_cert,
        ssl_cert_key:  ssl_cert_key,
        ssl_cert_pass: ssl_cert_pass,
        host:          feedback_host,
        port:          feedback_port
        )

      @deliver_session.on_sent(&method(:handle_sent))
      @deliver_session.on_error(&method(:handle_delivery_error))
      @deliver_session.on_exception(&method(:handle_exception))

      @feedback_session.on_error(&method(:handle_feedback))
      @feedback_session.on_exception(&method(:handle_exception))

      @deliver_session.start
      @feedback_session.start
    end

    def stop
      @deliver_session.stop
      @feedback_session.stop
    end

    def wait_stop
      @deliver_session.wait_stop
      @feedback_session.wait_stop
    end

    def deliver(notification)
      @deliver_session.push(notification)
    end

    def handle_delivery_error(notification, err)
      @on_delivery_error.call(notification, err) if @on_delivery_error
    end

    def handle_feedback(notification, err)
      @on_feedback.call(err.device_token) if @on_feedback
    end

    def handle_exception(e)
      @on_exception.call(e) if @on_exception
    end

    def handle_sent(notification)
      @on_sent.call(notification) if @on_sent
    end

    def on_delivery_error(&block)
      @on_delivery_error = block
    end

    # To attempt to connect to apns server and close actually
    # it used to check ssl cert files and ohter configurations.
    #
    # raises:
    #   ConnectionError: Unable to connect to apns. generaly socket error.
    #   SSLError:        Given invalid SSL Cert.
    #       
    def attempt_to_connect?
      @deliver_session.connect
      @deliver_session.close
    end

    [:feedback, :sent, :delivery_error, :exception].each do |event|
      event_name = "on_#{event}"
      define_method(event_name) do |&block|
        instance_variable_set("@#{event_name}", block)
      end
    end

    def on_exception(&block)
      @on_exception = block
    end
  end
end
