require 'dm-core'
require 'dm-types'
require 'dm-migrations'

require 'uri'
require 'net/http'

$:.unshift('.') unless $:.include?('.')
require '../protocol/basic'

DataMapper::Logger.new(File.open('/tmp/ohana.log', 'a'), :debug)
DataMapper.setup(:default, :adapter => 'sqlite', :path => File.expand_path(File.join(File.dirname(__FILE__), 'process.db')))

module Ohana
  module Process
    class ProcessStoreError < RuntimeError; end

    def self.fetch(name)
      Store.first(:name => name)
    end

    def self.list
      Store.all.map { |x| x.to_json }.to_json
    end

    def self.add(process)
      begin
        Store.create(process).to_json
      rescue DataObjects::IntegrityError
        Store.first(:name => process['name']).to_json
      end
    end

    def self.send_msg(msg)
      fetch(msg.process).send_msg(msg.channel, msg.content)
    end

	  class Store
	    include DataMapper::Resource
	
	    property :id,         Serial,        :key => true
      property :name,       String,        :required => true, :unique => true
	    property :type,       Discriminator, :required => true
	    property :uri,        String
	    property :spec,       Json
	    property :version,    String,        :required => true, :default => 1

      before :save do
        if !@uri && !@spec
          raise ProcessStoreError, "URI or Spec must be specified: uri: #{@uri}, spec: #{@spec}"
        end
      end
	
	    def spec
	      @spec ||= if spec_cache then ::Ohana::Protocol::ProcessSpec.parse(spec_cache)
	                else
	                  # fetch from spec_uri
	                  update(:spec_cache => JSON.parse(Net::HTTP.get(URI.parse(spec_uri))))
	                  ::Ohana::Protocol::ProcessSpec.parse(spec_cache)
	                end
	    end

      def channels; spec.channels end
	
	    def send_msg(channel, message)
	      if not channels.include?(channel)
	        raise ProcessStoreError, "Invalid channel: #{name} process does not have channel " + 
	          "#{channel}: #{channels.join(', ')} are valid."
	      end
	    end

      def to_json
        { :id       => id,
          :name     => name, 
          :type     => type,
          :uri      => uri,
          :spec     => spec,
          :version  => version  }.to_json
      end
	  end

	
	  class RESTful < Store
		  def send_msg(channel, message)
        super(channel, message)
        if spec.respond_to?(:root_uri)
	        res = Net::HTTP.post_form URI.parse("#{spec.root_uri}/channel/#{channel}"), { :message => message }
          res.body
        else
          raise ProcessStoreError, "spec must contain root_uri"
        end
	    end
	  end
  end
end

DataMapper.auto_migrate!
