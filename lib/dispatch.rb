require File.join(File.dirname(__FILE__), 'process')

module Ohana
  class Dispatch
    attr_reader :process

    @@methods = {
      'SEND' => lambda { |m| ::Ohana::Process.send_msg(m) },
      'ADD'  => lambda { |p| ::Ohana::Process.add(p) },
      'LIST' => lambda { |x| ::Ohana::Process.list }
    }

    def self.dispatch(request)
      @@methods[request.method].call(request.content)
    end
  end
end
