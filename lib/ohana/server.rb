require 'socket'

$:.unshift('.') unless $:.include?('.')
require File.join(File.dirname(__FILE__), 'protocol')
require 'server/log'
require 'server/dispatch'
require 'server/message_queue'

module Ohana
  HOST     = '127.0.0.1'.freeze
  PORT     = 3141
  MAX_KIDS = 3

  module Server
    def self.run(args=[])
      Daemon.run(args)
    end

	  class Daemon
	    extend Log
	
	    def self.exception(io, e)
	      msg = "#{e.class}: #{e.message}" #{e.backtrace.join("\n")}"
	      log.error msg
		    begin
	        io.puts server_error(msg).to_json
	      rescue
	        puts msg
	      end
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
	
	      begin
	        acceptor = Socket.new(:INET, :STREAM, 0)
	        address  = Socket.pack_sockaddr_in(PORT, HOST)
	        acceptor.bind(address)
	        acceptor.listen(10)
	      rescue Errno::EADDRINUSE => e
	        puts "'#{HOST}:#{PORT}' is already in use"
	        exit
	      rescue
	        raise $!
	      end
	
	      trap('EXIT') { acceptor.close }
	
	      MAX_KIDS.times do
	        fork do
	          trap('INT') { exit }
	
	          puts "child #$$ accepting on shared socket (#{HOST}:#{PORT})"
			      loop {
			        sock, addr = acceptor.accept
	            begin
			          req = Protocol::Request.parse(sock.gets)
			          log.info("REQUEST: #{req.inspect}")
                MessageQueue.push(req)
	              sock.write ok("message queued").to_json
	            rescue => e
	              exception sock, e
	            end
			        sock.close
	            puts "child #$$: #{req.inspect}"
			      }
	          exit
	        end
	      end
	
	      trap('INT') { puts "\ngoing down..."; exit }
	
	      ::Process.waitall
	    end
	  end
  end
end
