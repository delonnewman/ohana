require 'json'
require 'socket'

module Ohana
  module Dispatcher
    class Socket
      def receive(msg)
        puts "dispatching msg: #{msg.inspect}"
        if msg.to == 'process_base'
          puts msg.to_json
          run('localhost', 6283, msg.to_json)
        end
      end
  
      def run(host, port, req)
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
          out = sock.gets.to_s.chomp
          ::Process.kill 'TERM', kidpid
          begin
            out
          rescue => e
            "#{e.class}: #{e.message}"
          end
        else
  	      # child copies standard input to the socket
          sock.write "#{req}\n"
          exit
        end
      end
    end
  end
end
