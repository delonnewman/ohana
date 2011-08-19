$:.unshift File.dirname(__FILE__)
require 'ohana/messenger'

module Ohana
  VERSION = '0.0.2'.freeze

  def self.debug?
    @@debug ||= false
  end

  def self.run(args)
    @@debug = args[:debug]
    Messenger.new
  end
end
