require 'socket'

$:.unshift('.') unless $:.include?('.')
require File.join(File.dirname(__FILE__), 'protocol')
require 'server/log'
require 'server/dispatch'
require 'server/message_queue'

module Ohana
  HOST     = '127.0.0.1'.freeze
  PORT     = 3141
  MAX_KIDS = 5

  module Server
    def self.run(args=[])
      Daemon.run(args)
    end

	  class Daemon
	    extend Log
      extend Ohana::Protocol::DSL
	
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
	        when /(-d|--daemonize)/ then options[:daemonize] = true
	        end
	      end
	      options
	    end
	
	    def self.run(args=[])
	      ::Process.daemon if options(args)[:daemonize]

        MessageQueue.instance.adapter = StarlingAdapter.new
	
	      begin
	        acceptor = Socket.new(:INET, :STREAM, 0)
	        address  = Socket.pack_sockaddr_in(PORT, HOST)
	        acceptor.bind(address)
          puts "= Running Ohana on #{HOST}:#{PORT} PID: #$$ ="
          puts "= Forking #{MAX_KIDS} children +1 Dispatcher ="
          puts "Press Ctrl-C to shutdown."
	        acceptor.listen(10)
	      rescue Errno::EADDRINUSE => e
	        puts "'#{HOST}:#{PORT}' is already in use"
	        exit
	      rescue
	        raise $!
	      end
	
	      trap('EXIT') { acceptor.close }
	
        # Dispatcher
        disp_pid = fork do
	        trap('INT') { puts "dispatcher going down..."; exit }
	        
          puts "dispatcher #$$ up."
          loop {
            puts "looping..."
            if MessageQueue.size > 0
              Dispatch.request(MessageQueue.pop)
            else
              sleep 1
            end
          }
          exit
        end

	      MAX_KIDS.times do
	        fork do
	          trap('INT') { puts "\nchild #$$ going down..."; exit }
	
	          puts "child #$$ accepting on shared socket (#{HOST}:#{PORT})"
			      loop {
			        sock, addr = acceptor.accept
	            begin
			          req = Protocol::Request.parse(sock.gets)
	              sock.write await(req.from.channel, from(req.to.to_s), to(req.from.to_s)).to_json
			          log.info("REQUEST: #{req.inspect}")
                MessageQueue.push(req)
                puts "Q: #{MessageQueue.size}"
	            rescue => e
	              exception sock, e
	            end
			        sock.close
	            puts "child #$$: #{req.inspect}"
			      }
	          exit
	        end
	      end

	      trap('INT') { 
          puts "\ngoing down...";
          exit
        }
	
	      ::Process.waitall
	    end
	  end
  end
end
