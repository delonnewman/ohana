module Ohana
  module Dispatch
    attr_reader :process

    def initialize(process)
      @process = ::Ohana::Process.fetch(process)
    end

    def receive(content)
        @process.receive(content)
    end

    def send(content)
        @process.send(content)
    end
  end
end
