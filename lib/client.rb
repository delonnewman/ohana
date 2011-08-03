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

  def self.disconnect
    @@socket.close
    @@socket = nil
  end

  def self.request(method, content=nil)
    begin
      req = { :method  => method,
              :content => content }.to_json

      if @@socket
        @@socket.write(req)
        true
      else
        raise "A connection has not been established"
      end

    rescue
      raise $!
      false
    end
  end

  def self.send(process, channel, content)
    request 'SEND', :process => process, :channel => channel, :content => content
  end

  def self.list
    request 'LIST'
  end

  def self.add(type, name, spec_uri)
    request 'ADD', :type => type, :name => name, :spec_uri => spec_uri
  end
end
