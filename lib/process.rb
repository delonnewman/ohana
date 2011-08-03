require 'dm-core'
require 'dm-types'
require 'dm-migrations'

require 'uri'
require 'net/http'

DataMapper::Logger.new(File.open('/tmp/ohana.log', 'a'), :debug)
DataMapper.setup(:default, :adapter => 'sqlite', :path => File.expand_path(File.join(File.dirname(__FILE__), 'process.db')))

module Ohana
  module Process
    class ProcessError < RuntimeError; end
    class SpecParseError < ProcessError; end

    def self.fetch(name)
      if p = Store.first(:name => name) then p
      else
        raise ProcessError, "Could not find process '#{name}'"
      end
    end

    def self.list
      Store.all.map { |x| x.to_json }.to_json
    end

    def self.add(process)
      Store.create(process).to_json
    end

    def self.send_msg(msg)
      fetch(msg.process).send_msg(msg.channel, msg.content)
    end

	  class Spec
      def self.parse(spec)
        if spec.respond_to?(:keys)
          s = Struct.new(*spec.keys.map { |k| k.to_sym })
          s.new(*spec.values)
        else
          raise SpecParseError, "spec doesn't seem to be in the correct format: #{spec.inspect}"
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
	
	    def send_msg(channel, message)
	      if not channels.include?(channel)
	        raise ProcessError, "Invalid channel: #{name} process does not have channel " + 
	          "#{channel}: #{channels.join(', ')} are valid."
	      end
	    end

      def to_json
        { :id       => id,
          :name     => name, 
          :type     => type,
          :spec_uri => spec_uri,
          :version  => version  }.to_json
      end
	  end

	
	  class RESTful < Store
		  def send_msg(channel, message)
        super(channel, message)
        if spec.respond_to?(:root_uri)
	        Net::HTTP.post_form URI.parse("#{spec.root_uri}/channel/#{channel}"), { :message => message }
        else
          raise ProcessError, "spec must contain root_uri"
        end
	    end
	  end
  end
end

DataMapper.auto_migrate!
