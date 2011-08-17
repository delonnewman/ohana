require 'receiver'

module Ohana
  Message = Struct.new(:to, :from, :channel, :content)

  class ProcessError < RuntimeError; end
  class Process
    attr_accessor :name, :version
    @@callbacks  = {}
    @@properties = {}
    @@receiver   = :socket

    def initialize
      @version = 1
    end

    #
    # Class Methods
    #

    # set receive channel
    def self.receive(channel, %callback)
      @@callbacks[channel] = callback
    end

    # get list of channels
    def self.channels
      @@callback.keys
    end

    # specify receiver adapter to be used, default is :socket
    def self.receiver(adapter)
      @@receiver = adapter
    end

    # returns the process spec as a hash
    def spec
      @spec ||= { :name     => @name,
                  :version  => @version,
                  :type     => self.class.to_s, 
                  :channels => self.class.channels }
    end

    #
    # Instance Methods
    #
    
    # send message, on channel to process
    def receive(channel, message)
      if channel = @@callbacks[channel]
        channel.call(message)
      else
        raise ProcessError, "channel '#{channel}', not found"
      end
    end

  end
end
