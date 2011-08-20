require 'json'
require 'net/http'

module Ohana
  module Dispatcher
    class Restful
      attr_reader :host, :port

      def initialize(args={})
        @host     = args[:host]     || 'localhost'
        @port     = args[:port]     || 80
        @resource = args[:resource] || raise(ArgumentError, 'resource is required')
      end

      def get(params={})
        request Net::HTTP::Get.new(uri)
      end

      def put(params)
        req = Net::HTTP::Put.new(uri)
        req['content-type'] = "application/json"
        req.body = params.to_json
        request req
      end

      def post(params)
        req = Net::HTTP::Post.new(uri)
        req['content-type'] = "application/json"
        req.body = params.to_json
        request req
      end

      def delete(params={})
        request Net::HTTP::Delete.new(uri)
      end

      def request(req)
        res = Net::HTTP.start(@host, @port) { |http|http.request(req) }
        unless res.kind_of?(Net::HTTPSuccess)
          handle_error(req, res)
        end
        res
      end

      # channel in msg should come in the form:
      #   :'PUT - /'   # => {"id":3, "name":null}
      #   :'GET - /3'  # => {"id":3, "name":null}
      #   :'POST - /3' # msg = {"name":"Joe"} => {"id":3, "name":"Joe"}
      #   ...
      def deliver(msg)
        channel = parse_channel(msg.channel)
        send(channel.method, msg.content)
      end

      def uri
        @uri ||= [ 'http:/', "#@host:#@port", @resource ].join('/')
      end

      private

      def handle_error(req, res)
        e = RuntimeError.new("#{res.code}:#{res.message}\nMETHOD:" +
                             "#{req.method}\nURI:#{req.path}\n#{res.body}")
        raise e
      end
  end

      Channel = Struct.new(:method, :path)
      def parse_channel(ch)
        meth, path = ch.to_s.split(/\s+-\s+/)
        Channel.new(meth.downcase.to_sym, path) 
      end
    end
  end
end
