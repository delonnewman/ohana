require File.join(File.dirname(__FILE__), 'process')
require File.join(File.dirname(__FILE__), '..', 'protocol')
require File.join(File.dirname(__FILE__), '..', 'util')

module Ohana
  module Server
	  class DispatchError < RuntimeError; end
	  class Dispatch
      include Ohana::Serializable

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

      def dispatch; end

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
              await(@to.channel, from(@to.to_s), to(@from.to_s))
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
          begin
            ok(Process::Store.all.to_json, '[Process]')
          rescue => e
            server_error("#{e.class}: #{e.message}")
          end
        end
      end

      class Add < Dispatch
        def dispatch
          begin
            ok(Process::Store.create(@request.to_hash).to_json, 'Process')
          rescue => e
            server_error("#{e.class}: #{e.message}")
          end
        end
      end

      class Get < Dispatch
        def dispatch
          begin
            ok(Process::Store.first(:name => @request.process).to_json, 'Process')
          rescue => e
            server_error("#{e.class}: #{e.message}")
          end
        end
      end

      class Remove < Dispatch
        def dispatch
          begin
            ok(Process::Store.first(:name => @request.process).destory.to_json,
               'Process')
          rescue => e
            server_error("#{e.class}: #{e.message}")
          end
        end
      end
	  end # Dispatch
  end
end
