require 'socket'
require 'json'
require File.join(File.dirname(__FILE__), 'protocol')

module Ohana
  module Client
    def self.run(host, port, req)
      # create a tcp connection to the specified host and port
      sock = begin
               TCPSocket.open(host, port)
             rescue
               puts "can't connect to port #{port} on #{host}: #$!"
               exit
             end

      sock.autoclose = true # so output gets there right away

      kidpid = fork

      if kidpid
	      # parent copies the socket to standard output
        out = sock.gets.chomp
        Process.kill 'TERM', kidpid
        begin
          Ohana::Protocol::Response.parse(out)
        rescue => e
          client_error("#{e.class}: #{e.message}")
        end
      else
	      # child copies standard input to the socket
        sock.write "#{req}\n"
        exit
      end
    end
  end

  @@host = 'localhost'
  @@port = 3141

  def host=(val)
    @@host = val
  end
  def host; @@host end

  def port=(val)
    @@port = val
  end
  def port; @@port end

  def self.request(req)
    Ohana::Client.run @@host, @@port, req
  end

  def self.send_msg(*args)
    request Kernel.send_msg(*args).to_json
  end

  def self.add(*args)
    request Kernel.add(*args).to_json
  end

  def self.list
    request Kernel.list.to_json
  end

  def self.get(*args)
    request Kernel.get(*args).to_json
  end

  def self.remove(*args)
    request Kernel.remove(*args).to_json
  end
end
