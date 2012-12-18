module Mameapns
  class Notification
    include Options

    options :axion_id
    options :medium_id

    options :identifier, default: 0
    options :expiry, default: 86400
    options :device_token
    options :badge
    options :sound, default: "1.aiff"
    options :alert
    options :attributes_for_device
    options :related_infomation

    def device_token=(token)
      if !token.nil?
        @device_token = token.gsub(/[ <>]/, "")
      else
        @device_token = nil
      end
    end

    def as_json
      json = {}
      json['aps'] = {}
      json['aps']['alert'] = alert if alert
      json['aps']['badge'] = badge if badge
      json['aps']['sound'] = sound if sound
      json['aps'].merge!(attributes_for_device) if attributes_for_device
      json
    end

    def payload
      as_json.to_json
    end

    def payload_size
      payload.bytesize
    end

    def to_binary
      [1, identifier, expiry, 0, 32, device_token, 0, payload_size, payload].pack("cNNccH*cca*")
    end
  end
end
