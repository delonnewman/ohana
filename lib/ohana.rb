require 'socket'
require 'logger'
require 'optparse'
require 'json'

require File.join(File.dirname(__FILE__), 'dispatch')

module Ohana
  HOST    = '127.0.0.1'.freeze
  PORT    = 3141
  WORKERS = 3

  class Server
    def self.log
      @@log ||= Logger.new('/tmp/ohana.log')
    end

    def self.options(args)
			options = { :daemonize => false }
      args.each do |arg|
        case arg
        when /-(d|daemonize)/ then options[:daemonize] = true
        end
      end
      options
    end

    def self.run(args=[])
      ::Process.daemon if options(args)[:daemonize]

      acceptor = Socket.new(:INET, :STREAM, 0)
      address  = Socket.pack_sockaddr_in(PORT, HOST)
      acceptor.bind(address)
      acceptor.listen(10)

      @@pid = $$

      trap('EXIT') { acceptor.close }

      WORKERS.times do
        fork do
          trap('INT') { exit }

          puts "child #$$ accepting on shared socket (#{HOST}:#{PORT})"
		      loop {
		        sock, addr = acceptor.accept
		        msg = Message.parse(sock.gets)
		        log.info("MESSAGE: #{msg.inspect}")
		        log.info("DISPATCHED: #{msg.dispatch}")
		        sock.write Time.now
		        sock.close
            puts "child #$$: #{msg.inspect}"
		      }
          exit
        end
      end

      trap('INT') { puts "\ngoing down..."; exit }

      ::Process.waitall
    end
  end

  class Message
    attr_reader :process, :channel, :content

    def initialize(process, channel, content)
      @process = process || raise("Request error: process cannot be nil")
      @channel = channel || raise("Request error: channel cannot be nil")
      @content = content || raise("Request error: content cannot be nil")
    end

    def self.parse(str)
      msg = JSON.parse(str)
      new(msg['process'], msg['channel'], msg['content'])
    end

    def dispatch
      Dispatch.new(@process).send(@channel, @content)
    end
  end
end
