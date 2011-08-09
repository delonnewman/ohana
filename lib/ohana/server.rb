require 'socket'
require 'logger'
require 'optparse'
require 'json'

require File.join(File.dirname(__FILE__), 'dispatch')
$:.unshift('.') unless $:.include?('.')
require 'protocol'

module Ohana
  HOST = '127.0.0.1'.freeze
  PORT = 3141
  KIDS = 3

  class Server
    def self.log
      @@log ||= Logger.new('/tmp/ohana.log')
    end

    def self.exception(io, e)
      msg = "#{e.class}: #{e.message} \n#{e.backtrace.join("\n")}"
      log.error msg
	    begin
        io.puts msg
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

      KIDS.times do
        fork do
          trap('INT') { exit }

          puts "child #$$ accepting on shared socket (#{HOST}:#{PORT})"
		      loop {
		        sock, addr = acceptor.accept
            begin
		          req = Protocol::Request.parse(sock.gets)
		          log.info("REQUEST: #{req.inspect}")
              puts "REQUEST: #{req.inspect}"
	            begin
	              d = req.dispatch
			          log.info("DISPATCHED: #{d.inspect}")
                sock.puts d
	            rescue => e
                exception sock, e
	            end
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
