require File.join(File.dirname(__FILE__), 'ohana')
require 'socket'

module Ohana
  @@socket = nil

  def self.connect(host, port)
    begin
      @@socket ||= TCPSocket.new(host, port)
      true
    rescue
      false
    end
  end

  def self.send(process, channel, content)
    begin
      msg = { :process => process, :channel => channel, :content => content }.to_json
      p msg
      @@socket.write(msg)
      true
    rescue
      raise $!
      false
    end
  end
end
