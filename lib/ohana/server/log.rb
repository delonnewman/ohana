require 'logger'

module Ohana
  module Server
    module Log
	    def log
	      @log ||= Logger.new('/tmp/ohana.log')
	    end
    end
  end
end
