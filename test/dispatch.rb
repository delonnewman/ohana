require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'ohana', 'server', 'dispatch'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'ohana', 'protocol'))


class InvalidRequest
  def method; "INVALID" end
end

class SendRequest
  def method; "SEND" end
  def message; "Hola" end
  def to
    Ohana::Protocol::Location.new(:process => 'echo', :channel => 'say')
  end

  def from
    Ohana::Protocol::Location.new(:process => 'sleeper', :channel => 'sleep')
  end
end

class TestDispatch < Test::Unit::TestCase
  def test_dispatch_request
    assert_raise Ohana::Server::DispatchError do
      Ohana::Server::Dispatch.request(Object.new)
    end
  end

  def test_invalid_method
    assert_raise Ohana::Server::DispatchError do
      Ohana::Server::Dispatch.request(InvalidRequest.new)
    end
  end
end

class TestMessageDispatch < Test::Unit::TestCase
  def setup
    @req = Ohana::Server::Dispatch.request(SendRequest.new)
  end

  def test_type
    assert_instance_of Ohana::Server::Dispatch::Send, @req
  end
end
