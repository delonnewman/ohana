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
