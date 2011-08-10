require 'json'
require File.join(File.dirname(__FILE__), '..', 'util')

module Ohana
  module Protocol
    module Parser
      module ClassMethods
        extend Ohana::Util
	      def dispatch(hash)
	        new(hash_keys_to_sym(hash))
	      end
	
	      def parse(json)
	        hash = begin
	          JSON.parse(json)
	        rescue => e
	          raise ProtocolError, e
	        end
	        
	        unless hash.respond_to?(:[]) && hash.respond_to?(:keys)
	          raise ProtocolError, "It doesn't seem like the message was parsed correctly"
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
