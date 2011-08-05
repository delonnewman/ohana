require 'socket'
require 'json'

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
          if (json = JSON.parse(out)).is_a?(Array)
            json.map { |j| JSON.parse(j) }
          else
            json
          end
        rescue => e
          puts "#{e.class}: #{e.message}"
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

  @@methods = %w{ SEND ADD LIST }

  def host=(val)
    @@host = val
  end
  def host; @@host end

  def port=(val)
    @@port = val
  end
  def port; @@port end

  def self.request(method, content={})
    if (method == 'SEND' || method == 'ADD') && content == {}
      raise ArgumentError, "SEND and ADD must have content"
    end

    unless @@methods.include?(method)
      raise ArgumentError, "'#{method}' is not valid. Valid methods include '#{@@methods.join(', ')}'."
    end

    Ohana::Client.run @@host, @@port, { :method => method, :content => content }.to_json
  end

  def self.send(content)
    request 'SEND', content
  end

  def self.add(content)
    request 'ADD', content
  end

  def self.list
    request 'LIST'
  end
end
