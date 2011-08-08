require File.join(File.dirname(__FILE__), 'parser')
require File.join(File.dirname(__FILE__), 'basic')

module Ohana
  module Protocol
    class RequestError < RuntimeError; end
    class Request
      include Parser

      attr_reader :method

      def self.dispatch(j)
	      @@dispatch ||= {
	        'SEND'   => lambda { |j| Send.new(j) },
	        'LIST'   => lambda { |j| List.new(j) },
	        'ADD'    => lambda { |j| Add.new(j) },
	        'GET'    => lambda { |j| Get.new(j) },
	        'REMOVE' => lambda { |j| Remove.new(j) }
	      }

        if j['method'] && (methods = @@dispatch.keys).include?(j['method'])
          @@dispatch[j['method']].call(j)
        else
          raise RequestError, "'#{j['method']}' is invalid.  '#{method.join(', ')}' are valid." 
        end
      end

      def self.prop(name, opts={})
        
      end

      def initialize(args)
        @method = args['method'] || raise(RequestError, "method cannot be nil")
      end

      class Send < Request
        attr_reader :message
        def initialize(args)
          super(args)
          @to       = args['to']        || raise(RequestError, "to cannot be nil")
          @from     = args['from']      || raise(RequestError, 'from cannot be nil')
          @reply_to = args['reply_to']
          @message  = args['message']   || raise(RequestError, 'message cannot be nil')
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
        attr_reader :type, :name, :spec
        def initialize(args)
          super(args)
          @type = args['type'] || raise(RequestError, "type cannot be nil")
          @name = args['name'] || raise(RequestError, 'name cannot be nil')
          @spec = args['spec'] || raise(RequestError, 'spec cannot be nil')
        end
      end

      class Get < Request
        attr_reader :process
        def initialize(args)
          super(args)
          @process = args['process'] || raise(RequestError, "process cannot be nil")
        end
      end

      class Remove < Request
        attr_reader :process
        def initialize(args)
          super(args)
          @process = args['process'] || raise(RequestError, "process cannot be nil")
        end
      end

    end # Request
  end
end