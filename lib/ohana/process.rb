$:.unshift File.dirname(__FILE__)
require 'receiver'
require 'json'

module Ohana
  Message = Struct.new(:to, :channel, :content)

  class MalformedMessage < RuntimeError; end

  def Message.parse(json)
    h = JSON.parse(json)
    raise MalformedMessage, json unless h.is_a?(Hash)

    to, channel, content = h['to'], h['channel'], h['content']

    if to && channel && content
      new(to, channel, content)
    else
      raise MalformedMessage, "to, channel, and content are required"
    end
  end

  class ProcessError < RuntimeError; end
  class Process
    include Receiver

    attr_accessor :name, :version
    @@adapter      = :socket

    def initialize
      @version = 1
      @name    = self.class.to_s
    end

    #
    # Class Methods
    #

    # set receive channel
    def self.receive(channel, &callback)
      @@channels[channel] = callback
    end

    # get list of channels
    def self.channels
      @@channels.keys
    end

    def self.channels?
      not channels.empty?
    end

    # specify receiver adapter to be used, default is :socket
    def self.adapter(adapter, args={})
      @@adapter      = adapter
      @@adapter_args = args
    end

    def adapter; @@adapter end

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
    
    # deliver message, on channel to process
    def deliver(msg)
      if callback = @@channels[msg.channel.to_sym]
        callback.call(msg.content)
      else
        raise ProcessError, "channel '#{msg.channel}', not found"
      end
    end
    alias << deliver

  end
end
