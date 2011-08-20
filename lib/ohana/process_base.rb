$:.unshift File.dirname(__FILE__)
require 'process'
require 'process_base/process'

module Ohana
  class ProcessBaseError < RuntimeError; end
  class ProcessBase < Process
    adapter :restful, :port => 5984, :resource => 'process'

    receive :fetch do |name|
      
    end
  end
end
