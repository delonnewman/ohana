require File.join(File.dirname(__FILE__), 'parser')
require File.join(File.dirname(__FILE__), 'basic')

module Ohana
  module Protocol
    class RepsonseError < RuntimeError; end
    class Response
      include Parser

      attr_reader :status
      
      def self.dispatch(j)
	      @@dispatch ||= {
	        'AWAIT'      => lambda { |j| Await.new(j) },
	        'NORESPONSE' => lambda { |j| NoResponse.new(j) },
	        'ERROR'      => lambda { |j| Error.new(j) }
	      }

        if j['method'] && (methods = @@dispatch.keys).include?(j['method'])
          @@dispatch[j['method']].call(j)
        else
          raise RequestError, "'#{j['method']}' is invalid.  '#{method.join(', ')}' are valid." 
        end
      end

      def initialize(args)
        @method = args['status'] || raise(RequestError, "status cannot be nil")
      end

      class Await < Response

      end
    end
  end
end
