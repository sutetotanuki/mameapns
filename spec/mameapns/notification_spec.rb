require "spec_helper"

module Mameapns
  describe Notification do
    it "should strip chevrons from the given string" do
      notification = Mameapns::Notification.new(device_token: "<aa>")
      notification.device_token.should eq "aa"
    end
    
    it "should strip spaces from the given string" do
      notification = Mameapns::Notification.new(device_token: "a a a")
      notification.device_token.should eq "aaa"
    end
    
    it "should default the sound to 1.aiff" do
      Mameapns::Notification.new.sound.should eq "1.aiff"
    end
    
    it "should default the expiry to 1 day" do
      Mameapns::Notification.new.expiry.should eq 86400
    end
    
    describe "#as_json" do
      it "should include the alert if present" do
        notification = Mameapns::Notification.new(alert: "aaa")
        notification.as_json["aps"]["alert"].should eq "aaa"
      end
      
      it "should not include the alert key if the alert is not present" do
        notification = Mameapns::Notification.new
        notification.as_json["aps"].key?("alert").should be_false
      end
      
      it "should include the badge if present" do
        notification = Mameapns::Notification.new(badge: 6)
        notification.as_json["aps"]["badge"].should eq 6
      end
      
      it "should not include the badge key if the badge is not present" do
        notification = Mameapns::Notification.new
        notification.as_json["aps"].key?("badge").should be_false
      end
      
      it "should include attributes for the device" do
        notification = Mameapns::Notification.new
        notification.attributes_for_device = { "koko" => "hore", "wan" => "wan" }
        notification.as_json["aps"]["koko"].should eq "hore"
        notification.as_json["aps"]["wan"].should eq "wan"
      end
    end
    
    describe "#to_binary" do
      it "should correctly convert the notification to binary" do
        notification = Mameapns::Notification.new({
            identifier: 37,
            alert: "abc",
            device_token: "79e9b418e64ee99c4236a2cf5270e6b3421b8e2672a97670888829abe529c5e4"
          })
        
        notification.to_binary.should eq "\x01\x00\x00\x00%\x00\x01Q\x80\x00 y\xE9\xB4\x18\xE6N\xE9\x9CB6\xA2\xCFRp\xE6\xB3B\e\x8E&r\xA9vp\x88\x88)\xAB\xE5)\xC5\xE4\x00({\"aps\":{\"alert\":\"abc\",\"sound\":\"1.aiff\"}}"
      end
    end
  end
end

