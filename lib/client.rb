require 'socket'

module Ohana
  @@socket = nil

  def self.connect(host, port)
    @@socket.close if @@socket
    @@socket = TCPSocket.open(host, port)
  end

  def self.disconnect
    @@socket.close
    @@socket = nil
  end

  def self.request(method, content=nil)
    req = { :method  => method,
            :content => content }.to_json

    if @@socket
      @@socket.write(req)

      buff = ""
      while ( (data = @@socket.recvfrom(100)) != "")
        p data
        buff += data
      end
      buff
    else
      raise "A connection has not been established"
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
