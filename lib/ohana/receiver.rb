
module Ohana
  module Receiver
    class Adapter
      def initialize(adapter, args={})
        klass_name = adapter.to_s.capitalize.gsub(/_(\w)/) { $1.upcase }.to_sym
        load File.join(File.dirname(__FILE__), 'receiver', "#{adapter.to_s}.rb")

        if Ohana::Receiver.constants.include?(klass_name)
          @klass = Ohana::Receiver.const_get(klass_name)
        else
          raise RuntimeError, "Adapter #{adapter.inspect}, is not valid"
        end
      end

      def spawn(process, args)
        @klass.new(process, args).spawn
      end
    end
  end
end
