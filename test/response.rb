require 'test/unit'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require "ohana/protocol"
require 'json'

module ResponseTestHelpers
  module ClassMethods
	  def status stat
      define_method :test_status do
        assert_equal stat, @res.status
      end
	  end
	
	  def type type
      define_method :test_type do
        assert_instance_of type, @res
      end
	  end
	
	  def prop name, type, value=nil
      if value
		    define_method :"test_#{name}" do
		      assert_equal value, @res.send(name.to_sym)
		    end
      end
		
      if type
		    define_method :"test_#{name}" do
		      assert_instance_of type, @res.send(name.to_sym)
		    end
      end
	  end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def response= res
    @res = res
  end
end

class TestAwait < Test::Unit::TestCase
  include ResponseTestHelpers

  type   Ohana::Protocol::Response::Await
  status 'AWAIT'

  prop 'to',      Ohana::Protocol::Location
  prop 'from',    Ohana::Protocol::Location
  prop 'channel', String

  def setup
    @json = { :status => 'AWAIT',
                :to => { :process => 'echo', :channel => 'say' },
                :from => { :process => 'sleeper', :channel => 'sleep' },
                :channel => 'say' }.to_json

    self.response = Ohana::Protocol::Response.parse(@json)
  end

  def test_nil
    assert_not_nil Ohana::Protocol::Response.parse(@json)
  end

  def test_no_to
    json = { :status => 'AWAIT',
                :from => { :process => 'sleeper', :channel => 'sleep' },
                :channel => 'say' }.to_json


    assert_raise Ohana::Protocol::ResponseError do
      Ohana::Protocol::Response.parse(json)
    end
  end

  def test_no_from
    json = { :status => 'AWAIT',
                :to => { :process => 'sleeper', :channel => 'sleep' },
                :channel => 'say' }.to_json


    assert_raise Ohana::Protocol::ResponseError do
      Ohana::Protocol::Response.parse(json)
    end
  end

  def test_no_channel
    json = { :status => 'AWAIT',
                :to => { :process => 'echo', :channel => 'say' },
                :from => { :process => 'sleeper', :channel => 'sleep' } }.to_json

    assert_raise Ohana::Protocol::ResponseError do
      Ohana::Protocol::Response.parse(json)
    end
  end
end

class TestNoResponse < Test::Unit::TestCase
  include ResponseTestHelpers

  type Ohana::Protocol::Response::NoResponse
  status 'NORESPONSE'

  def setup
    @json = { :status => 'NORESPONSE',
                :to => { :process => 'echo', :channel => 'say' },
                :from => { :process => 'sleeper', :channel => 'sleep' } }.to_json
    self.response = Ohana::Protocol::Response.parse(@json)
  end
end

class TestError < Test::Unit::TestCase
  include ResponseTestHelpers

  type Ohana::Protocol::Response::Error
  status 'ERROR'

  prop 'message', String, 'this is an error'

  def setup
    @json = { :status => 'ERROR',
                :to => { :process => 'echo', :channel => 'say' },
                :from => { :process => 'sleeper', :channel => 'sleep' },
                :message => 'this is an error' }.to_json
    self.response = Ohana::Protocol::Response.parse(@json)
  end
end
