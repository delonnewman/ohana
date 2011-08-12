require 'singleton'
require 'starling'
require 'posix_mq'

require File.join(File.dirname(__FILE__), '..', 'protocol')

module Ohana
  module Server
    class MessageQueue
      include Singleton

      def initialize
        @size  = 0
        @queue = []
      end
      
      def adapter=(adapter)
        @queue = adapter
      end

      def size
        if @queue.respond_to?(:size)
          @queue.size
        else
          @size
        end
      end

      def push(x)
        @size += 1
        @queue.push(x)
      end

      def pop
        @size -= 1 if @size > 0
        @queue.pop
      end

      def clear
        @size = 0
        @queue.clear
      end

      class << self
        def method_missing(meth, *args, &block)
          instance.send(meth, *args, &block)
        end
      end
    end

    class POSIXAdapter
      def initialize
        @queue = POSIX_MQ.open('/ohana', :rw)
      end

      def push(x)
        @queue << x.to_json
      end

      def pop
        Ohana::Protocol::Request.parse(@queue.shift)
      end

      def clear
        @queue.nonblock = true
        @queue.shift while @queue.shift
        @queue.nonblock = false
      end
    end

    class StarlingAdapter
      def initialize
        @queue = Starling.new('localhost:22122')
        @name  = 'ohana'
      end

      def push(x)
        @queue.set(@name, x)
      end

      def pop
        @queue.get(@name)
      end

      def clear
        @queue.flush(@name)
      end

      def size
        @queue.sizeof(@name)
      end
    end
  end
end
