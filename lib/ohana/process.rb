$:.unshift File.dirname(__FILE__)
require 'receiver'
require 'json'
require File.join(File.dirname(__FILE__), 'util')

module Ohana
  class Message
    include Serializable

    attr_accessor :to, :channel, :content

    class ParseError < RuntimeError; end

    def initialize(to, channel, content)
      @to, @channel, @content = to, channel, content
    end

    def self.parse(json)
      h = begin
        JSON.parse(json)
      rescue => e
        raise ParseError, "#{e.class}: #{json.inspect}\n " + 
          "#{e.message}, #{e.backtrace.join("\n")}" 
      end
      
      raise ParseError, json unless h.is_a?(Hash)
  
      to, channel, content = h['to'], h['channel'], h['content']
  
      if to && channel && content
        new(to, channel, content)
      else
        raise ParseError, "to, channel, and content are required: #{h.inspect}, #{json.inspect}"
      end
    end
  end

  class ProcessError < RuntimeError; end
  class Process
    DEBUG = true

    attr_accessor :name, :version

    @@adapter       = :default
    @@adapter_args  = {}
    @@adapter_class = nil
    @@channels      = {}
    @@properties    = {}

    def initialize(name=self.class.to_s, args={})
      @version    = 1
      @name       = name

      @adapter      = args[:adapter]      || @@adapter
      @adapter_args = args[:adapter_args] || @@adapter_args

      if @adapter != :default
        @receiver   = Receiver::Adapter.new(@adapter, @adapter_args)
        @dispatcher = Dispatcher::Adapter.new(@adapter, @adapter_args)
      end
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

    # test if there are any channels specified
    def self.channels?
      not channels.empty?
    end

    # specify receiver adapter to be used
    def self.adapter(adapter, args={})
      @@adapter      = adapter
      @@adapter_args = args
    end

    #
    # Instance Methods
    #

    # returns the process spec as a hash
    def spec
      @spec ||= { :name     => @name,
                  :version  => @version,
                  :type     => self.class.to_s, 
                  :channels => self.class.channels }
    end

    # spawn process via named adapter or as a lightweight fiber
    def spawn(&block)
      if @receiver
        @receiver.spawn(self, @@adapter_args)
      else
        @receiver ||= Fiber.new(&block)
      end
    end

    # receive messages via adapter or fiber
    def receive(msg)
      if @dispatcher
        if @dispatcher.respond_to?(:resume)
          @dispatcher.resume(msg)
        else
          @dispater.deliver(msg)
        end
      else
        @dispatcher ||= @receiver.resume(msg)
      end
    end
    alias << receive
  end
end
