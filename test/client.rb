require 'test/unit'

$lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require "#{$lib}/ohana"
require "#{$lib}/client"
require 'json'

class TestClient < Test::Unit::TestCase
  def setup
    Ohana.connect('localhost', 3141)
  end

  def teardown
  end

  def test_connection
    assert Ohana.connect('localhost', 3141), "should connect to localhost:3141"
  end

  def test_send
    assert Ohana.send(:echo, :say, "hello it's #{Time.now} from TestClient"), "send should return true"
  end

  def test_add
    assert Ohana.add('RESTful', :echo, 'http://locahost:4567/process.json')
  end
end


