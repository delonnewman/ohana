require File.join(File.dirname(__FILE__), 'process')
require File.join(File.dirname(__FILE__), '..', 'protocol')

module Ohana
  module Server
	  class DispatchError < RuntimeError; end
	  class Dispatch
		  def self.message(req)
		    Dispatch::Message.new(req).dispatch
		  end
		  
	    class Message #< Dispatch
	      attr_reader :request, :from, :to
	
	      def initialize(req)
	        @request = req
	        @from    = req.from
	        @to      = req.to
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
	            end
	          end
	        else
	          raise DispatchError, "Could not find process: '#{@to.process}'"
	        end
	      end
	    end
	  end
  end
end
