require 'socket'
require 'json'

module Ohana
  module Dispatcher
    class Adapter
      def initialize(adapter, args={})
        klass_name = adapter.to_s.capitalize.gsub(/_(\w)/) { $1.upcase }.to_sym
        load File.join(File.dirname(__FILE__), 'dispatcher', "#{adapter.to_s}.rb")

        if Ohana::Dispatcher.constants.include?(klass_name)
          @klass = Ohana::Dispatcher.const_get(klass_name)
        else
          raise RuntimeError, "Adapter #{adapter.inspect}, is not valid"
        end
      end

      def deliver(msg)
        @klass.deliver(msg)
      end
    end
  end
end
