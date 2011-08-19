# TODO: autoload adapters
$:.unshift File.join(File.dirname(__FILE__), 'receiver')
require 'preforker'

module Ohana
  module Receiver
    # a mixin for Ohana::Process
    @@adapter      = nil
    @@adapter_args = {}
    @@channels     = {}
    @@properties   = {}

    def receive(msg)
      
    end

    def await
      Preforker.await(self, @@adapter_args)
    end
  end
end
