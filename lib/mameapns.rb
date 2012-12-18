require "thread"
require "openssl"
require "json"

module Mameapns
  require "mameapns/error"
  require "mameapns/version"
  
  autoload :Options,            'mameapns/options'
  autoload :Notification,       'mameapns/notification'
  autoload :Application,        'mameapns/application'
  autoload :Session,            'mameapns/session'
  autoload :InterruptibleSleep, 'mameapns/interruptible_sleep'
  autoload :Connection,         'mameapns/connection'

  def self.new(options)
    Application.new(options)
  end
end
