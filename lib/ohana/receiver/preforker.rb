require 'socket'
require File.join(File.dirname(__FILE__), '..', 'server', 'log')

module Ohana
  module Receiver
    class Preforker
	    include ::Ohana::Server::Log

	    def exception(io, e)
	      msg = "#{e.class}: #{e.message} #{e.backtrace.join("\n")}"
	      log.error msg
		    begin
	        io.puts server_error(msg).to_json
	      rescue
	        puts msg
	      end
	    end
	
      attr_reader :daemon, :host, :port, :workers

	    def initialize(process, args={})
        @daemon      = args[:daemon]      || false
        @host        = args[:host]        || 'localhost'.freeze
        @port        = args[:port]        || 3141 # make a random port?
        @workers     = args[:workers]     || 5    # number of workers to maintain
        @max_clients = args[:max_clients] || 5
        @process     = process
      end

      alias daemon? daemon

      # run server, fork workers
      def spawn
        ::Process.daemon if daemon?

	      begin
	        acceptor = Socket.new(:INET, :STREAM, 0)
	        address  = Socket.pack_sockaddr_in(@port, @host)
	        acceptor.bind(address)
          unless daemon?
	          puts "-= Running #{@process.name} on #@host:#@port PID: #$$ =-"
	          puts "-= Forking #@workers children =-"
	          puts "Press Ctrl-C to shutdown."
          end
	        acceptor.listen(10)
	      rescue Errno::EADDRINUSE => e
	        puts "'#{host}:#{port}' is already in use"
	        exit
	      rescue
	        raise $!
	      end
	
	      trap('EXIT') { acceptor.close }
	
        # fork workers ('children')
	      workers.times do
          fork_worker(acceptor)
	      end

        # kill all children for a clean exit
	      trap('INT') { 
          puts "\ngoing down..."
          exit
        }

	      ::Process.waitall
	    end

      private

      def fork_worker(acceptor)
        fork do
          trap('INT') { exit }

          puts "child #$$ accepting on shared socket (#@host:#@port)"
		      loop {
		        sock, addr = acceptor.accept
            begin
                sock.puts @process.deliver(Ohana::Message.parse(sock.gets))
            rescue => e
              exception sock, e
            end
		        sock.close
		      }
          exit
        end
      end

    end
  end
end
