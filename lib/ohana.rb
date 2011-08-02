require 'socket'

module Ohana
  HOST = '127.0.0.1'.freeze
  PORT = 3141

  class Server
    def self.run(args=[])
      server = TCPServer.new(HOST, PORT)
      loop {
        s = server.accept
        s.puts Time.now
        s.close
      }
    end
  end
end
