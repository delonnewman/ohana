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
    adapter :preforker, :workers => 5

    def initialize
      super()
      await # enters await mode upon initialization 
    end

    receive :route do |msg|
      Dispatcher.dispatch(msg)
    end

  end
end
