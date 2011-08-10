require File.join(File.dirname(__FILE__), 'parser')
require File.join(File.dirname(__FILE__), 'basic')
require File.join(File.dirname(__FILE__), '..', 'util')

module Ohana
  module Protocol
    class RequestError < RuntimeError; end
    class Request
      include Parser
      extend Ohana::Util

      attr_reader :method

      def self.dispatch(h)
        h = hash_keys_to_sym h
	      methods = {
	        'SEND'   => lambda { |h| Send.new(h) },
	        'LIST'   => lambda { |h| List.new(h) },
	        'ADD'    => lambda { |h| Add.new(h) },
	        'GET'    => lambda { |h| Get.new(h) },
	        'REMOVE' => lambda { |h| Remove.new(h) }
	      }

        if h[:method] && methods.keys.include?(h[:method])
          methods[h[:method]].call(h)
        else
          raise RequestError, "'#{h[:method]}' is invalid.  " +
            "'#{methods.keys.join(', ')}' are valid." 
        end
      end

      def initialize(args)
        @method = args[:method] || raise(RequestError, "method cannot be nil")
      end

      def to_json
        h = {}
        instance_variables.each do |var|
          h[var.to_s.sub('@', '')] = instance_variable_get(var)
        end
        h.to_json
      end

      class Send < Request
        attr_reader :message

        def initialize(args)
          super(args)
          @to       = args[:to]        || raise(RequestError, "to cannot be nil")
          @from     = args[:from]      || raise(RequestError, 'from cannot be nil')
          @reply_to = args[:reply_to]
          @message  = args[:message]   || raise(RequestError, 'message cannot be nil')
        end

        def to
          ::Ohana::Protocol::Location.new(@to)
        end

        def from
          ::Ohana::Protocol::Location.new(@from)
        end

        def reply_to
          ::Ohana::Protocol::Location.new(@reply_to) if @reply_to
        end
      end

      class List < Request; end

      class Add < Request
        attr_reader :type, :name, :uri

        def initialize(args)
          super(args)
          @type = args[:type] || raise(RequestError, "type cannot be nil")
          @name = args[:name] || raise(RequestError, 'name cannot be nil')
          @spec = args[:spec]
          @uri  = args[:uri]

          if !@spec && !@uri
            raise RequestError, "must provide process spec or uri"
          end
        end

        def spec
          ProcessSpec.new(@spec) if @spec
        end
      end

      class Get < Request
        attr_reader :process

        def initialize(args)
          super(args)
          @process = args[:process] || raise(RequestError, "process cannot be nil")
        end
      end

      class Remove < Request
        attr_reader :process

        def initialize(args)
          super(args)
          @process = args[:process] || raise(RequestError, "process cannot be nil")
        end
      end

    end # Request
  end
end
