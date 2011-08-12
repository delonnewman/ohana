require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'ohana', 'server', 'message_queue'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'ohana', 'protocol'))

class TestMessageQueue < Test::Unit::TestCase
  def setup
    Ohana::Server::MessageQueue.instance.adapter = Ohana::Server::POSIXAdapter.new
    Ohana::Server::MessageQueue.clear
  end

  def test_push
    assert_equal 0, Ohana::Server::MessageQueue.size
    Ohana::Server::MessageQueue.push("Aloha!")
    assert_equal 1, Ohana::Server::MessageQueue.size
    Ohana::Server::MessageQueue.push("Hola!")
    assert_equal 2, Ohana::Server::MessageQueue.size
    Ohana::Server::MessageQueue.push("Hola!")
    assert_equal 3, Ohana::Server::MessageQueue.size
  end

  def test_pop
    Ohana::Server::MessageQueue.push("Aloha!")
    assert_equal "Aloha!", Ohana::Server::MessageQueue.pop
    assert_equal 0, Ohana::Server::MessageQueue.size
  end

  def test_clear
    Ohana::Server::MessageQueue.push("Aloha!")
    assert_equal 1, Ohana::Server::MessageQueue.size
    Ohana::Server::MessageQueue.clear
    assert_equal 0, Ohana::Server::MessageQueue.size
  end

  def test_request_integration
    Ohana::Server::MessageQueue.push(send_msg("Miredita!", to('echo/say'), from('sleeper/sleep')))
    Ohana::Server::MessageQueue.push(send_msg("Miredita!", to('echo/say'), from('sleeper/sleep')))
    assert_equal 2, Ohana::Server::MessageQueue.size
  end
end
