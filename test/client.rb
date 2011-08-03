require 'test/unit'

$lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require "#{$lib}/ohana"
require "#{$lib}/client"
require 'json'

unless Ohana::Process.fetch('test')
  Ohana::Process::RESTful.create(:name => 'test', :spec_uri => 'http://localhost:4567/process.json')
end

class TestMessage < Test::Unit::TestCase
  def setup
    @process = 'test'
    @channel = 'say'
    @content = "hello it's #{Time.now} from TestMessage"
    @msg = Ohana::Message.parse({:process => @process, :channel => @channel, :content => @content}.to_json)
  end

  def test_process
    assert_equal @process, @msg.process, "should equal test"
  end

  def test_channel
    assert_equal @channel, @msg.channel, "should equal say"
  end

  def test_message
    assert_equal @content, @msg.content, "should equal hello"
  end

  def test_dispatch
    assert @msg.dispatch, "should return true"
  end
end

class TestClient < Test::Unit::TestCase
  def test_connection
    assert Ohana.connect('localhost', 3141), "should connect to localhost:3141"
  end

  def test_send
    assert Ohana.send(:test, :say, "hello it's #{Time.now} from TestClient"), "send should return true"
  end
end


