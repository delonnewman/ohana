require File.expand_path(File.join(File.dirname(__FILE__), '../../test/protocol/helpers'))

class TestSend < Test::Unit::TestCase
  include RequestTestHelpers

  type   Ohana::Protocol::Request::Send
  method 'SEND'

  prop 'to',       Ohana::Protocol::Location
  prop 'from',     Ohana::Protocol::Location
  prop 'reply_to', Ohana::Protocol::Location
  prop 'message',  String, 'Aloha!'

  def setup
    @json = send_msg('Aloha!', to('echo/channel'), from('sleeper/sleep'), reply_to('sleeper/say')).to_json

    self.request = Ohana::Protocol::Request.parse(@json)
  end

  def test_nil
    assert_not_nil Ohana::Protocol::Request.parse(@json)
  end

  def test_reply_to_nil
    json = send_msg('Aloha!', to('echo/channel'), from('sleeper/sleep')).to_json

    req = Ohana::Protocol::Request.parse(json)

    assert_equal nil, req.reply_to
  end

  def test_no_to
    json = send_msg('Aloha!', {}, from('sleeper/sleep')).to_json

    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end

  def test_no_from
    json = send_msg('Aloha!', to('echo/channel'), {}).to_json

    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end

  def test_no_message
    json = send_msg(nil, to('echo/channel'), from('sleeper/sleep')).to_json

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
    @json = list.to_json
    self.request = Ohana::Protocol::Request.parse(@json)
  end
end

class TestAdd < Test::Unit::TestCase
  include RequestTestHelpers

  type Ohana::Protocol::Request::Add
  method 'ADD'

  prop 'type', String, 'RESTful'
  prop 'name', String, 'echo'
  prop 'uri', String, 'http://localhost:4567/process.json'

  def setup
    @json = add('echo', 'RESTful', :uri => 'http://localhost:4567/process.json').to_json
    self.request = Ohana::Protocol::Request.parse(@json)
  end

  def test_with_spec
    json = add('echo', 'RESTful', spec('echo', 'RESTful', :root_uri => 'http://localhost:4567', :channels => ['say'])).to_json
    req = Ohana::Protocol::Request.parse(json)
    assert_instance_of Ohana::Protocol::Request::Add, req
    assert_equal 'echo', req.name
    assert_equal 'RESTful', req.type
    assert_not_nil req.spec
    assert_instance_of Ohana::Protocol::ProcessSpec, req.spec
    assert_equal 'echo', req.spec.name
    assert_equal 'http://localhost:4567', req.spec.root_uri
    assert_instance_of Array, req.spec.channels
    assert_equal 1, req.spec.channels.count
    assert_equal 'say', req.spec.channels.first
  end

  def test_with_no_spec_and_no_uri
    json = add('echo', 'RESTful', {}).to_json
    
    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end
end

class TestGet < Test::Unit::TestCase
  include RequestTestHelpers

  type Ohana::Protocol::Request::Get
  method 'GET'

  prop 'process', String, 'echo'

  def setup
    @json = get("echo").to_json
    self.request = Ohana::Protocol::Request.parse(@json)
  end

  def test_without_process
    json = get(nil).to_json

    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end
end

class TestRemove < Test::Unit::TestCase
  include RequestTestHelpers

  type Ohana::Protocol::Request::Remove
  method 'REMOVE'

  prop 'process', String, 'echo'

  def setup
    @json = remove("echo").to_json
    self.request = Ohana::Protocol::Request.parse(@json)
  end

  def test_without_process
    json = remove(nil).to_json

    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end
end
