require 'process'
require 'process_base/process'

module Ohana
  class ProcessBaseError < RuntimeError; end
  class ProcessBase < Process
    receiver :preforker

    # reply with a particular process in PB
    receive :fetch do |name|
      begin
	      if p = Process.get(name)
	        reply p
	      else
	        raise ProcessBaseError, "Could not find '#{name}'"
	      end
      rescue
        reply_error e 
      end
    end

    # reply with a list of all processes in PB
    receive :list do
      begin
        reply Process.all
      rescue => e
        reply_error e 
      end
    end

    # remove named process from PB, return process
    receive :remove do |name|
      begin
	      if p = Process.get(name).destory
	        reply p
	      else
	        raise ProcessBaseError, "Could not remove '#{name}'"
	      end
      rescue
        reply_error e 
      end
    end

    # create process from given hash
    recieve :add do |process|
      begin
	      if p = Process.create(process)
	        reply p
	      else
	        raise ProcessBaseError, "Could not create '#{name}'"
	      end
      rescue
        reply_error e 
      end
    end
  end
end
