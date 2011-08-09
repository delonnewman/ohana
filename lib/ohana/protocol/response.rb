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
	        'ERROR'      => lambda { |j| Error.new(j) },
          'OK'         => lambda { |j| OK.new(j) }
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
          @to      = args['to']      || raise(ResponseError, "to cannot be nil")
          @from    = args['from']    || raise(ResponseError, "from cannot be nil")
          @channel = args['channel'] || raise(ResponseError, "channel cannot be nil")
        end
      end

      class NoResponse < Response
        def initialize(args)
          super(args)
          @to   = args['to']   || raise(ResponseError, "to cannot be nil")
          @from = args['from'] || raise(ResponseError, "from cannot be nil")
        end
      end

      class Error < Response
        attr_reader :message

        @@errors = %w{ PROCESS_ERROR SERVER_ERROR }

        def initialize(args)
          super(args)
          @message = args['message'] || raise(ResponseError, "message cannot be nil")
          @type    = args['type']    || raise(ResponseError, "type cannot be nil")
          @to      = args['to']
          @from    = args['from']

          unless @@errors.include?(@type)
            raise(ResponseError, "'#{@type}' is invalid; '#{@@errors.join(',')}' are valid error types.")
          end

          if @type == 'PROCESS_ERROR' && ( !@to || !@from )
            raise(ResponseError, "Errors of type SendError require from and to")
          end
        end
      end

      class OK < Response
        attr_reader :content_type

        def initialize(args)
          super(args)
          @content      = args['content']      || raise(ResponseError, "content cannot be nil")
          @content_type = args['content_type'] || 'String'
        end

        def content
          if @ccontent then @ccontent
          else
	          content_types = {
	            'String'    => lambda { @content.to_json },
	            'Process'   => lambda { Process.new(@content) },
	            '[Process]' => lambda { @content.map { |c| Process.new(c) } }
	          }
	
	          unless (types = content_types.keys).include?(@content_type)
	            raise ResponseError, "'#{@content_type}' is invalid, " +
	              "'#{types.join(', ')}' are valid content types."
	          end
	
	          @ccontent = content_types[@content_type].call
          end
        end
      end
    end
  end
end
