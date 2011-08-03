require File.join(File.dirname(__FILE__), 'process')

module Ohana
  class Dispatch
    attr_reader :process

    def initialize(process)
      @process = ::Ohana::Process.fetch(process)
    end

    def receive(channel, message)
      @process.receive(channel, message)
    end

    def send(channel, message)
      @process.send(channel, message)
    end
  end
end
