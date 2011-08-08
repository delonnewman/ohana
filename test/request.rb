require 'test/unit'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require "ohana/protocol"
require 'json'

class TestLocation < Test::Unit::TestCase
  def setup
    @json = '{"process":"echo","channel":"say"}'
    @loc  = Ohana::Protocol::Location.parse(@json)
  end

  def test_type
    assert_instance_of Ohana::Protocol::Location, @loc
  end

  def test_process
    assert_equal 'echo', @loc.process
  end

  def test_channel
    assert_equal 'say', @loc.channel
  end
end

module RequestTestHelpers
  module ClassMethods
	  def method meth
      define_method :test_method do
        assert_equal meth, @req.method
      end
	  end
	
	  def type type
      define_method :test_type do
        assert_instance_of type, @req
      end
	  end
	
	  def prop name, type, value=nil
      if value
		    define_method :"test_#{name}" do
		      assert_equal value, @req.send(name.to_sym)
		    end
      end
		
      if type
		    define_method :"test_#{name}" do
		      assert_instance_of type, @req.send(name.to_sym)
		    end
      end
	  end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def request= req
    @req = req
  end
end

class TestSend < Test::Unit::TestCase
  include RequestTestHelpers

  type   Ohana::Protocol::Request::Send
  method 'SEND'

  prop 'to',       Ohana::Protocol::Location
  prop 'from',     Ohana::Protocol::Location
  prop 'reply_to', Ohana::Protocol::Location
  prop 'message',  String, 'Aloha!'

  def setup
    @json = { :method => 'SEND',
                :to => { :process => 'echo', :channel => 'say' },
                :from => { :process => 'sleeper', :channel => 'sleep' },
                :reply_to => { :process => 'sleeper', :channel => 'say' },
                :message => 'Aloha!' }.to_json

    self.request = Ohana::Protocol::Request.parse(@json)
  end

  def test_nil
    assert_not_nil Ohana::Protocol::Request.parse(@json)
  end

  def test_reply_to_nil
    json = { :method => 'SEND',
                :to => { :process => 'echo', :channel => 'say' },
                :from => { :process => 'sleeper', :channel => 'sleep' },
                :message => 'Aloha!' }.to_json

    req = Ohana::Protocol::Request.parse(json)

    assert_equal nil, req.reply_to
  end

  def test_no_to
    json = { :method => 'SEND',
                :from => { :process => 'sleeper', :channel => 'sleep' },
                :message => 'Aloha!' }.to_json


    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end

  def test_no_from
    json = { :method => 'SEND',
                :to => { :process => 'sleeper', :channel => 'sleep' },
                :message => 'Aloha!' }.to_json


    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end

  def test_no_message
    json = { :method => 'SEND',
                :to => { :process => 'echo', :channel => 'say' },
                :from => { :process => 'sleeper', :channel => 'sleep' } }.to_json

    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end
end

class TestList < Test::Unit::TestCase
  include RequestTestHelpers

  type Ohana::Protocol::Request::List
  method 'LIST'

  def setup
    @json = '{"method":"LIST"}'
    self.request = Ohana::Protocol::Request.parse(@json)
  end
end

class TestAdd < Test::Unit::TestCase
  include RequestTestHelpers

  type Ohana::Protocol::Request::Add
  method 'ADD'

  prop 'type', String, 'RESTful'
  prop 'name', String, 'echo'
  prop 'spec', String, 'http://localhost:4567/process.json'

  def setup
    @json =<<-JSON
      {"method":"ADD",
        "type":"RESTful",
        "name":"echo",
        "spec":"http://localhost:4567/process.json"}
    JSON
    self.request = Ohana::Protocol::Request.parse(@json)
  end
end

class TestGet < Test::Unit::TestCase
  include RequestTestHelpers

  type Ohana::Protocol::Request::Get
  method 'GET'

  prop 'process', String, 'echo'

  def setup
    @json =<<-JSON
      {"method":"GET",
        "process":"echo"}
    JSON
    self.request = Ohana::Protocol::Request.parse(@json)
  end
end

class TestRemove < Test::Unit::TestCase
  include RequestTestHelpers

  type Ohana::Protocol::Request::Remove
  method 'REMOVE'

  prop 'process', String, 'echo'

  def setup
    @json =<<-JSON
      {"method":"REMOVE",
        "process":"echo"}
    JSON
    self.request = Ohana::Protocol::Request.parse(@json)
  end
end
