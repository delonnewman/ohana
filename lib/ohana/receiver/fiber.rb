
module Ohana
  module Receiver
    class Fiber
      include Receiver

      def initialize(process, args)
        @process = process
        @args    = args
        @f = Fiber.new { |msg|
          @process.deliver(msg)
        }
      end

      def receive(msg)
        @f.resume(msg)
      end
    end
  end
end
