require File.join(File.dirname(__FILE__), 'parser')
require File.join(File.dirname(__FILE__), 'basic')

module Ohana
  module Protocol
    class ResponseError < RuntimeError; end
    class Response
      include Parser

      attr_reader :status
      
      def self.dispatch(j)
	      @@dispatch = {
	        'AWAIT'      => lambda { |j| Await.new(j) },
	        'NORESPONSE' => lambda { |j| NoResponse.new(j) },
	        'ERROR'      => lambda { |j| Error.new(j) }
	      }

        if j['status'] && (statuses = @@dispatch.keys).include?(j['status'])
          @@dispatch[j['status']].call(j)
        else
          raise ResponseError, "'#{j['status']}' is invalid.  " +
            "'#{statuses.join(', ')}' are valid." 
        end
      end

      def initialize(args)
        @status = args['status'] || raise(ResponseError, "status cannot be nil")
        @to     = args['to']     || raise(ResponseError, "to cannot be nil")
        @from   = args['from']   || raise(ResponseError, "from cannot be nil")
      end


      def to
        ::Ohana::Protocol::Location.new(@to)
      end

      def from
        ::Ohana::Protocol::Location.new(@from)
      end

      class Await < Response
        attr_reader :channel

        def initialize(args)
          super(args)
          @channel = args['channel'] || raise(ResponseError, "channel cannot be nil")
        end
      end

      class NoResponse < Response; end

      class Error < Response
        attr_reader :message

        def initialize(args)
          super(args)
          @message = args['message'] || raise(ResponseError, "message cannot be nil")
        end
      end
    end
  end
end
