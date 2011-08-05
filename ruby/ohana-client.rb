#!/usr/bin/env ruby
# biclient - bidirectional forking client
require 'socket'
require 'json'

module Ohana
  module Client
    def self.run(host, port, req)
      # create a tcp connection to the specified host and port
      sock = begin
               TCPSocket.open(host, port)
             rescue
               puts "can't connect to port #{port} on #{host}: #$!"
               exit
             end

      sock.autoclose = true # so output gets there right away

      kidpid = fork

      if kidpid
	      # parent copies the socket to standard output
        out = sock.gets.chomp
        Process.kill 'TERM', kidpid
        begin
          if (json = JSON.parse(out)).is_a?(Array)
            json.map { |j| JSON.parse(j) }
          else
            json
          end
        rescue => e
          puts "#{e.class}: #{e.message}"
        end
      else
	      # child copies standard input to the socket
        sock.write "#{req}\n"
        exit
      end
    end
  end

  @@host = 'localhost'
  @@port = 3141

  @@methods = %w{ SEND ADD LIST }

  def self.request(method, content={})
    if (method == 'SEND' || method == 'ADD') && content == {}
      raise ArgumentError, "SEND and ADD must have content"
    end

    unless @@methods.include?(method)
      raise ArgumentError, "'#{method}' is not valid. Valid methods include '#{@@methods.join(', ')}'."
    end

    Ohana::Client.run @@host, @@port, { :method => method, :content => content }.to_json
  end

  def self.send(content)
    request 'SEND', content
  end

  def self.add(content)
    request 'ADD', content
  end

  def self.list
    request 'LIST'
  end
end

if $0 == __FILE__
  require 'test/unit'
  require 'json'

  Ohana::Client.run('localhost', 3141, '{"method":"ADD", "content":{"type":"RESTful", "name":"echo", "spec_uri":"http://localhost:4567/process.json"}}')
  class TestClient < Test::Unit::TestCase
    def setup
      @type = 'Ohana::Process::RESTful'
      @name = 'echo'
      @uri  = 'http://localhost:4567/process.json'
    end

    def test_raw_list
      res = Ohana::Client.run('localhost', 3141, '{"method":"LIST"}')
      assert_instance_of Array, res
      assert_equal 1, res.size
      assert_instance_of Hash, res.first
      assert_equal @type, res.first['type']
      assert_equal @name, res.first['name']
      assert_equal @uri,  res.first['spec_uri']
    end

    def test_raw_add
      res = Ohana::Client.run('localhost', 3141, '{"method":"ADD", "content":{"type":"RESTful", "name":"echo", "spec_uri":"http://localhost:4567/process.json"}}')
      assert_instance_of Hash, res
      assert_equal @type, res['type']
      assert_equal @name, res['name']
      assert_equal @uri,  res['spec_uri']
    end

    def test_raw_send
      res = Ohana::Client.run 'localhost', 3141, '{"method":"SEND", "content":{"process":"echo", "channel":"say", "content":"hola"}}'
      assert_instance_of Hash, res
      assert_equal 'echo', res['process']
      assert_equal 'say',  res['channel']
      assert_equal 'Do you speak Spanish?', res['content']
    end

    def test_list
      res = Ohana.list
      assert_instance_of Array, res
      assert_equal 1, res.size
      assert_instance_of Hash, res.first
      assert_equal @type, res.first['type']
      assert_equal @name, res.first['name']
      assert_equal @uri,  res.first['spec_uri']
    end

    def test_add
      res = Ohana.add :type => "RESTful", :name => "echo", :spec_uri => "http://localhost:4567/process.json"
      assert_instance_of Hash, res
      assert_equal @type, res['type']
      assert_equal @name, res['name']
      assert_equal @uri,  res['spec_uri']
    end

    def test_send
      res = Ohana.send :process => "echo", :channel => "say", :content => "hola"
      assert_instance_of Hash, res
      assert_equal 'echo', res['process']
      assert_equal 'say',  res['channel']
      assert_equal 'Do you speak Spanish?', res['content']
    end
  end
end
