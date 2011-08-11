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
    @json =<<-JSON
      {"method":"SEND",
        "to": {"process":"echo", "channel":"say"},
        "from": {"process":"sleeper", "channel":"sleep" },
        "reply_to": {"process":"sleeper", "channel":"say"},
        "message":"Aloha!" }
    JSON

    self.request = Ohana::Protocol::Request.parse(@json)
  end

  def test_nil
    assert_not_nil Ohana::Protocol::Request.parse(@json)
  end

  def test_reply_to_nil
    json =<<-JSON
      {"method":"SEND",
        "to": {"process":"echo", "channel":"say"},
        "from": {"process":"sleeper", "channel":"sleep" },
        "message": "Aloha!" }
    JSON

    assert_nothing_raised do
      @req = Ohana::Protocol::Request.parse(json)
    end

    assert_equal nil, @req.reply_to
  end

  def test_no_to
    json =<<-JSON
      {"method":"SEND",
        "from": {"process":"sleeper", "channel":"sleep" },
        "reply_to": {"process":"sleeper", "channel":"say"},
        "message":"Aloha!" }
    JSON

    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end

  def test_no_from
    json =<<-JSON
      {"method":"SEND",
        "to": {"process":"echo", "channel":"say"},
        "reply_to": {"process":"sleeper", "channel":"say"},
        "message":"Aloha!" }
    JSON

    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end

  def test_no_message
    json =<<-JSON
      {"method":"SEND",
        "to": {"process":"echo", "channel":"say"},
        "from": {"process":"sleeper", "channel":"sleep" },
        "reply_to": {"process":"sleeper", "channel":"say"} }
    JSON

    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end
end

class TestList < Test::Unit::TestCase
  include RequestTestHelpers

  type Ohana::Protocol::Request::List
  method 'LIST'

  prop 'to',       Ohana::Protocol::Location
  prop 'from',     Ohana::Protocol::Location
  prop 'reply_to', Ohana::Protocol::Location

  def setup
    @json =<<-JSON
      {"method":"LIST",
        "to": {"process":"echo", "channel":"say"},
        "from": {"process":"sleeper", "channel":"sleep" },
        "reply_to": {"process":"sleeper", "channel":"say"} }
    JSON
    self.request = Ohana::Protocol::Request.parse(@json)
  end
end

class TestAdd < Test::Unit::TestCase
  include RequestTestHelpers

  type Ohana::Protocol::Request::Add
  method 'ADD'

  prop 'to',       Ohana::Protocol::Location
  prop 'from',     Ohana::Protocol::Location
  prop 'reply_to', Ohana::Protocol::Location
  prop 'type',     String, 'RESTful'
  prop 'name',     String, 'echo'
  prop 'uri',      String, 'http://localhost:4567/process.json'

  def setup
    @json =<<-JSON
      {"method":"ADD",
        "to": {"process":"echo", "channel":"say"},
        "from": {"process":"sleeper", "channel":"sleep" },
        "reply_to": {"process":"sleeper", "channel":"say"},
        "name":"echo",
        "type":"RESTful",
        "uri": "http://localhost:4567/process.json" }
    JSON
    self.request = Ohana::Protocol::Request.parse(@json)
  end

  def test_with_spec
    json =<<-JSON
      {"method":"ADD",
        "to": {"process":"echo", "channel":"say"},
        "from": {"process":"sleeper", "channel":"sleep" },
        "reply_to": {"process":"sleeper", "channel":"say"},
        "name":"echo",
        "type":"RESTful",
        "spec": {"name":"echo","type":"RESTful", "root_uri":"http://localhost:4567","channels":["say"]} }
    JSON
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
    json =<<-JSON
      {"method":"ADD",
        "to": {"process":"echo", "channel":"say"},
        "from": {"process":"sleeper", "channel":"sleep" },
        "reply_to": {"process":"sleeper", "channel":"say"},
        "name":"echo",
        "type":"RESTful" }
    JSON
    
    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end
end

class TestGet < Test::Unit::TestCase
  include RequestTestHelpers

  type Ohana::Protocol::Request::Get
  method 'GET'

  prop 'to',       Ohana::Protocol::Location
  prop 'from',     Ohana::Protocol::Location
  prop 'reply_to', Ohana::Protocol::Location
  prop 'process',  String, 'echo'

  def setup
    @json =<<-JSON
      {"method":"GET",
        "to": {"process":"echo", "channel":"say"},
        "from": {"process":"sleeper", "channel":"sleep" },
        "reply_to": {"process":"sleeper", "channel":"say"},
        "process":"echo" }
    JSON
    self.request = Ohana::Protocol::Request.parse(@json)
  end

  def test_without_process
    json =<<-JSON
      {"method":"GET",
        "to": {"process":"echo", "channel":"say"},
        "from": {"process":"sleeper", "channel":"sleep" },
        "reply_to": {"process":"sleeper", "channel":"say"} }
    JSON

    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end
end

class TestRemove < Test::Unit::TestCase
  include RequestTestHelpers

  type Ohana::Protocol::Request::Remove
  method 'REMOVE'

  prop 'to',       Ohana::Protocol::Location
  prop 'from',     Ohana::Protocol::Location
  prop 'reply_to', Ohana::Protocol::Location
  prop 'process',  String, 'echo'

  def setup
    @json =<<-JSON
      {"method":"REMOVE",
        "to": {"process":"echo", "channel":"say"},
        "from": {"process":"sleeper", "channel":"sleep" },
        "reply_to": {"process":"sleeper", "channel":"say"},
        "process":"echo" }
    JSON
    self.request = Ohana::Protocol::Request.parse(@json)
  end

  def test_without_process
    json =<<-JSON
      {"method":"REMOVE",
        "to": {"process":"echo", "channel":"say"},
        "from": {"process":"sleeper", "channel":"sleep" },
        "reply_to": {"process":"sleeper", "channel":"say"} }
    JSON

    assert_raise Ohana::Protocol::RequestError do
      Ohana::Protocol::Request.parse(json)
    end
  end
end
