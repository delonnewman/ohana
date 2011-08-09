require File.join(File.dirname(__FILE__), 'process')

module Ohana
  def self.dispatch(message)
    Dispatch::Request.new(message)  if message.is_a?(Ohana::Protocol::Request)
    Dispatch::Response.new(message) if message.is_a?(Ohana::Protocol::Response)
  end
  
  module Dispatch
    class Request #< Dispatch
      attr_reader :request

      def initialize(req)
        @request = req
      end
    end

    class Response #< Dispatch
      attr_reader :response

      def initialize(res)
        @response = res
      end

      def dispatch
      end
    end
  end
end
