require File.join(File.dirname(__FILE__), 'process')
require File.join(File.dirname(__FILE__), '..', 'protocol')
require File.join(File.dirname(__FILE__), '..', 'util')
require File.join(File.dirname(__FILE__), 'message_queue')

module Ohana
  module Server
	  class DispatchError < RuntimeError; end
	  class Dispatch
      include Ohana::Serializable
      include Ohana::Protocol::DSL
      include Log

      METHODS = Ohana::Protocol::Request::METHODS
	    @@method_dispatch = {
	      METHODS[0] => lambda { |req| Send.new(req).dispatch },
	      METHODS[1] => lambda { |req| List.new(req).dispatch },
	      METHODS[2] => lambda { |req| Add.new(req).dispatch },
	      METHODS[3] => lambda { |req| Get.new(req).dispatch },
	      METHODS[4] => lambda { |req| Remove.new(req).dispatch }
	    }

		  def self.request(req)
        begin
          method = req.method

          if method && METHODS.include?(method)
            @@method_dispatch[method].call(req)
          else
            raise DispatchError, "'#{method}' is invalid. " +
              "'#{METHODS.join(', ')}' are valid."
          end
        rescue ArgumentError
          raise DispatchError, "Invalid request '#{req.inspect}' " +
            "does not respond to 'method'"
        end
		  end

      attr_reader :request
		  
      def initialize(req)
        @request = req
      end

      def dispatch(&block)
        begin
          block.call(@request)
          log.info("DISPATCHED: #{@request.inspect}")
          puts "DISPATCHED: #{@request.inspect}"
        rescue => e
          server_error("#{e.class} - #{e.message}")
          log.error("ERROR: #{e.class}: #{e.message}\n #{e.backtrace.join("\n")}")
          if p = Process.fetch(@request.from.process)
            p.send_msg(process_error(e))
          end
        end
      end

	    class Send < Dispatch
	      attr_reader :from, :to
	
	      def initialize(req)
	        super(req)
	        @from = req.from
	        @to   = req.to
	      end
	
	      def dispatch
	        if p = Process.fetch(@to.process)
	          begin
	            p.send_msg(@request.message)
	          rescue => e
	            begin
	              p = Process.fetch(@from.process)
	              p.send_msg(process_error(e))            
	            rescue => e
	              log.error(server_error(e))
              ensure
                server_error(e)
	            end
	          end
	        else
	          raise DispatchError, "Could not find process: '#{@to.process}'"
	        end
	      end
	    end

      class List < Dispatch
        def dispatch
          super { |req|
            MessageQueue.push(
              send_msg(Process.list, from(req.to.to_s), to(req.from.to_s))
            )
          }
        end
      end

      class Add < Dispatch
        def dispatch
          super { |req|
            MessageQueue.push(
              send_msg Process.add(req.to_hash), from(req.to.to_s), to(req.from.to_s)
            )
          }
        end
      end

      class Get < Dispatch
        def dispatch
          super { |req|
            if p = Process.fetch(req.process)
	            MessageQueue.push(
	              send_msg p, from(req.to.to_s), to(req.from.to_s)
	            )
            else
              raise DispatchError, "can't find process '#{req.process}'"
            end
          }
        end
      end

      class Remove < Dispatch
        def dispatch
          super { |req|
            if p = Process.fetch(req.process)
	            MessageQueue.push(
	              send_msg p.destroy, from(req.to.to_s), to(req.from.to_s)
	            )
            else
              raise DispatchError, "can't find process '#{req.process}'"
            end
          }
        end
      end
	  end # Dispatch
  end
end
