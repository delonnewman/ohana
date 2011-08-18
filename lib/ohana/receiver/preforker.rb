require 'preforker'

module Ohana
  module Receiver
    class Preforker
	    #extend Log

	    def exception(io, e)
	      msg = "#{e.class}: #{e.message}" #{e.backtrace.join("\n")}"
	      log.error msg
		    begin
	        io.puts server_error(msg).to_json
	      rescue
	        puts msg
	      end
	    end
	
      attr_reader :daemon, :host, :port, :workers

	    def initialize(args={}, &block)
        @daemon  = args[:daemonize] || args[:daemon] || false
        @host    = args[:host]    || 'localhost'
        @port    = args[:port]    || 3141
        @workers = args[:workers] || 5
        @block   = block
      end

      alias daemon? daemon

      def run
	      begin
	        acceptor = Socket.new(:INET, :STREAM, 0)
	        address  = Socket.pack_sockaddr_in(@port, @host)
	        acceptor.bind(address)
          unless daemon?
	          puts "-= Running Ohana::Receiver::Preforker on #@host:#@port PID: #$$ =-"
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
	
	      workers.times do
	        fork do
	          trap('INT') { puts "\nchild #$$ going down..."; exit }
	
	          puts "child #$$ accepting on shared socket (#@host:#@port)"
			      loop {
			        sock, addr = acceptor.accept
	            begin
                sock.puts @block.call(self, sock.gets)
	            rescue => e
	              exception sock, e
	            end
			        sock.close
	            #puts "child #$$: #{req.inspect}"
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
