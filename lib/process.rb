require 'dm-core'
require 'dm-types'
require 'dm-migrations'

require 'uri'
require 'net/http'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite:///#{File.expand_path(File.join(File.dirname(__FILE__), '..', 'extra', 'process.db'))}")

module Ohana
  module Process
    def self.fetch(name)
      Store.first(:name => name)
    end

	  class Spec
      def self.parse(spec)
        if spec.respond_to?(:keys)
          s = Struct.new(*spec.keys.map { |k| k.to_sym })
          s.new(*spec.values)
        else
          raise "Parse error: spec doesn't seem to be in the correct format: #{spec.inspect}"
        end
      end
	  end
	
	  class Store
	    include DataMapper::Resource
	
	    property :id,         Serial,        :key => true
      property :name,       String,        :required => true, :unique => true
	    property :type,       Discriminator, :required => true
	    property :spec_uri,   String,        :required => true
	    property :spec_cache, Json
	    property :version,    String,        :required => true, :default => 1
	
	    def spec
	      @spec ||= if spec_cache then Spec.parse(spec_cache)
	                else
	                  # fetch from spec_uri
	                  update(:spec_cache => JSON.parse(Net::HTTP.get(URI.parse(spec_uri))))
	                  Spec.parse(spec_cache)
	                end
	    end

      def channels; spec.channels end
	
	    def send(channel, message)
	      if not channels.include?(channel)
	        raise "Invalid channel: #{name} process does not have channel " + 
	          "#{channel}: #{channels.join(', ')} are valid."
	      end
	    end
	  end

	
	  class RESTful < Store
	    def send(channel, message)
        super(channel, message)
        if spec.respond_to?(:root_uri)
	        Net::HTTP.post_form URI.parse("#{spec.root_uri}/channel/#{channel}"), { :message => message }
        else
          raise "Spec error: spec must contain root_uri"
        end
	    end
	  end
  end
end

DataMapper.auto_migrate!
