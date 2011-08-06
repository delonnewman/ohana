require File.join(File.dirname(__FILE__), 'parser')

module Ohana
  module Protocol
    class Location
      include Parser
      attr_reader :process, :channel
      def initialize(args)
        @process = args['process'] || raise(ProtocolError, "process cannot be nil")
        @channel = args['channel'] || raise(ProtocolError, "channel cannot be nil")
      end
    end

    class Process
      include Parser
      attr_reader :name, :uri
      def initialize(args)
        @name = args['name']
        @spec = args['spec']
        @uri  = args['uri']

        if !@name && !@spec && !@uri
          raise ProtocolError, "Process must be identified by name, spec or uri: spec: " + 
            "#{@spec.inspect}, name: #{@name.inspect} :uri #{@uri.inspect}"
        end
      end

      def spec
        @ps ||= ProcessSpec.new(@spec) if @spec
      end
    end

    class ProcessSpec
      include Parser
      attr_reader :name, :version, :type, :channels
      def initialize(args)
        @name     = args['name']     || raise(ProtocolError, "name cannot be nil")
        @version  = args['version']
        @type     = args['type']     || raise(ProtocolError, "type cannot be nil")
        @channels = args['channels'] || raise(ProtocolError, "channels cannot be nil")
      end
    end
  end
end
