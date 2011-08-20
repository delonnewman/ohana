$:.unshift File.dirname(__FILE__)
require 'process'
require 'dispatcher'

#
# A core process subclass of Process, can receive 
# messages on channel :route, for forwarding messages
# to other processes.
#

module Ohana
  class Messenger < Process
    adapter :preforker, :port => 3141

    receive :route do |msg|
      puts "receiving: #{msg.inspect} on :route"
      res = Dispatcher.dispatch(Message.new(msg['to'], msg['channel'], msg['content']))
      puts "from #{msg['to'].inspect}: #{res.inspect}"
    end
  end
end
