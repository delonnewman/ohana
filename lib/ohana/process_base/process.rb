require 'dm-core'
require 'dm-types'
require 'dm-migrations'

require 'uri'
require 'net/http'
require 'json'

require File.join(File.dirname(__FILE__), 'process')

module Ohana
  class ProcessBase < ::Ohana::Process
    DataMapper::Logger.new(File.open('/tmp/ohana-process-base.log', 'a'), :debug)
    DataMapper.setup(:default, :adapter => 'sqlite',
                     :path => File.expand_path(File.join(File.dirname(__FILE__), 'process.db')))

    ProcessSpec = Struct.new(:name, :version, :type, :channels)

    class ProcessBaseStorageError < RuntimeError; end

    class Process
      include DataMapper::Resource
    
      property :id,         Serial,        :key => true
      property :name,       String,        :required => true, :unique => true
      property :type,       Discriminator, :required => true
      property :uri,        String
      property :spec,       Json
      property :version,    String,        :required => true, :default => 1
    
    
      before :save do
        if !@uri && !@spec
          raise ProcessBaseStorageError, "URI or Spec must be specified: uri: #{@uri}, spec: #{@spec}"
        end
      end
    
      # return ProcessSpec based on spec from DB if present, otherwise look for 
      # it by fetching from uri, result is cached. On error can will return ProcessBaseStorageError
      def spec
        @scache ||= if @spec then
          ProcessSpec.new(@spec[:name], @spec[:version], @spec[:type], @spec[:channels])
        else
          begin
            json = JSON.parse(Net::HTTP.get(URI.parse(uri)))
          rescue
            raise ProcessBaseStorageError, $!
          end

          unless update(:spec => json)
            raise ProcessBaseStorageError, "cannot update spec for process, id: #@id, name: #@name"
          end

          ProcessSpec.new(@spec[:name], @spec[:version], @spec[:type], @spec[:channels])
        end
      end
    
      # returns channels from spec method
      def channels; spec.channels end

      # converts stored process to json
      def to_json
        { :id       => id,
          :name     => name, 
          :type     => type,
          :uri      => uri,
          :spec     => spec,
          :version  => version }.to_json
      end
    end

#    class Message
#      include DataMapper::Resource
#    end

    DataMapper.auto_migrate!
  end
end
