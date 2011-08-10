require File.expand_path(File.join(File.dirname(__FILE__), '../../test/protocol/helpers'))

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

class TestProcessSpec < Test::Unit::TestCase
  def setup
    @json = '{"name":"echo","version":"1","type":"RESTful","channels":["say"]}'
    @proc = Ohana::Protocol::ProcessSpec.parse(@json)
  end

  def test_type
    assert_instance_of Ohana::Protocol::ProcessSpec, @proc
  end

  def test_name
    assert_equal 'echo', @proc.name
  end

  def test_version
    assert_equal '1', @proc.version
  end

  def test_type
    assert_equal 'RESTful', @proc.type
  end

  def test_channels
    assert_instance_of Array, @proc.channels
    assert_equal 1, @proc.channels.count
    assert_equal 'say', @proc.channels.first
  end
end

class TestProcess < Test::Unit::TestCase
  def test_name
    json = '{"name": "echo"}'
    p    = Ohana::Protocol::Process.parse(json)
    assert_instance_of Ohana::Protocol::Process, p
    assert_equal 'echo', p.name
  end

  def test_uri
    json = '{"process":"echo","uri": "http://localhost:4567/process.json"}'
    p    = Ohana::Protocol::Process.parse(json)
    assert_instance_of Ohana::Protocol::Process, p
    assert_equal 'http://localhost:4567/process.json', p.uri
  end

  def test_spec
    json = '{"process":"echo", "spec": { "name":"echo","version":"1","type":"RESTful","channels":["say"] } }'
    p    = Ohana::Protocol::Process.parse(json)
    assert_instance_of Ohana::Protocol::Process, p
    assert_instance_of Ohana::Protocol::ProcessSpec, p.spec
  end

  def test_no_spec_name_or_uri
    json = '{"process": null}'
    assert_raise Ohana::Protocol::ProtocolError do
      Ohana::Protocol::Process.parse(p)
    end
  end

  def test_uri_with_no_name
    json = '{"uri": "http://localhost:4567/process.json"}'
    assert_raise Ohana::Protocol::ProtocolError do
      Ohana::Protocol::Process.parse(json)
    end
  end
end
