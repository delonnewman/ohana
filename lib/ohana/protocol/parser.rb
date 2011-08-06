require 'json'

module Ohana
  module Protocol
    module Parser
      module ClassMethods
	      def dispatch(hash)
	        new(hash)
	      end
	
	      def parse(json)
	        hash = begin
	          JSON.parse(json)
	        rescue => e
	          raise ProtocolError, e
	        end
	        
	        unless hash.respond_to?(:[]) && hash.respond_to?(:keys)
	          raise ProtocolError, "It doesn't seem like the request was parsed correctly"
	        end

          dispatch(hash)
	      end
      end

      def self.included(klass)
        klass.extend(ClassMethods)
      end
    end

    class ProtocolError < RuntimeError; end
  end
end
