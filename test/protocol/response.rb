require File.expand_path(File.join(File.dirname(__FILE__), '../../test/protocol/helpers'))

class TestAwait < Test::Unit::TestCase
  include ResponseTestHelpers

  type   Ohana::Protocol::Response::Await
  status 'AWAIT'

  prop 'to',      Ohana::Protocol::Location
  prop 'from',    Ohana::Protocol::Location
  prop 'channel', String, 'say'

  def setup
    @json =<<-JSON
      {"status":"AWAIT",
        "channel":"say",
        "from": {"process":"sleeper", "channel":"sleep"},
        "to": {"process":"echo", "channel":"say"} }
    JSON

    self.response = Ohana::Protocol::Response.parse(@json)
  end

  def test_nil
    assert_not_nil Ohana::Protocol::Response.parse(@json)
  end

  def test_no_to
    json =<<-JSON
      {"status":"AWAIT",
        "channel":"say",
        "from": {"process":"sleeper", "channel":"sleep"} }
    JSON

    assert_raise Ohana::Protocol::ResponseError do
      Ohana::Protocol::Response.parse(json)
    end
  end

  def test_no_from
    json =<<-JSON
      {"status":"AWAIT",
        "channel":"say",
        "to": {"process":"echo", "channel":"say"} }
    JSON


    assert_raise Ohana::Protocol::ResponseError do
      Ohana::Protocol::Response.parse(json)
    end
  end

  def test_no_channel
    json =<<-JSON
      {"status":"AWAIT",
        "from": {"process":"sleeper", "channel":"sleep"},
        "to": {"process":"echo", "channel":"say"} }
    JSON

    assert_raise Ohana::Protocol::ResponseError do
      Ohana::Protocol::Response.parse(json)
    end
  end
end

class TestNoResponse < Test::Unit::TestCase
  include ResponseTestHelpers

  type Ohana::Protocol::Response::NoResponse
  status 'NORESPONSE'

  prop 'to',   Ohana::Protocol::Location
  prop 'from', Ohana::Protocol::Location

  def setup
    @json =<<-JSON
      {"status":"NORESPONSE",
        "from": {"process":"sleeper", "channel":"sleep"},
        "to": {"process":"echo", "channel":"say"} }
    JSON

    self.response = Ohana::Protocol::Response.parse(@json)
  end


  def test_without_to
    json =<<-JSON
      {"status":"NORESPONSE",
        "from": {"process":"sleeper", "channel":"sleep"} }
    JSON

    assert_raise Ohana::Protocol::ResponseError do 
      Ohana::Protocol::Response.parse(json)
    end
  end

  def test_without_from
    json =<<-JSON
      {"status":"NORESPONSE",
        "to": {"process":"echo", "channel":"say"} }
    JSON

    assert_raise Ohana::Protocol::ResponseError do 
      Ohana::Protocol::Response.parse(json)
    end
  end
end

class TestError < Test::Unit::TestCase
  include ResponseTestHelpers

  type Ohana::Protocol::Response::Error
  status 'ERROR'

  prop 'message', String, 'this is an error'
  prop 'type',    String, 'PROCESS_ERROR'
  prop 'to',      Ohana::Protocol::Location
  prop 'from',    Ohana::Protocol::Location

  def setup
    @json =<<-JSON
      {"status":"ERROR",
        "type": "PROCESS_ERROR",
        "message": "this is an error",
        "from": {"process":"sleeper", "channel":"sleep"},
        "to": {"process":"echo", "channel":"say"} }
    JSON

    self.response = Ohana::Protocol::Response.parse(@json)
  end

  def test_send_error_without_to
    json =<<-JSON
      {"status":"ERROR",
        "type": "PROCESS_ERROR",
        "message": "this is an error",
        "from": {"process":"sleeper", "channel":"sleep"} }
    JSON

    assert_raise Ohana::Protocol::ResponseError do 
      Ohana::Protocol::Response.parse(json)
    end
  end

  def test_send_error_without_from
    json =<<-JSON
      {"status":"ERROR",
        "type": "PROCESS_ERROR",
        "message": "this is an error",
        "to": {"process":"echo", "channel":"say"} }
    JSON

    assert_raise Ohana::Protocol::ResponseError do 
      Ohana::Protocol::Response.parse(json)
    end
  end

  def test_server_error_without_from_or_to
    json =<<-JSON
      {"status":"ERROR",
        "type": "SERVER_ERROR",
        "message": "this is an error" }
    JSON

    assert_nothing_raised do
      Ohana::Protocol::Response.parse(json)
    end
  end

  def test_with_invalid_error_type
    json =<<-JSON
      {"status":"ERROR",
        "type": "INVALID_ERROR",
        "message": "this is an error" }
    JSON

    assert_raise Ohana::Protocol::ResponseError do
      Ohana::Protocol::Response.parse(json)
    end
  end
end

class TestOK < Test::Unit::TestCase
  include ResponseTestHelpers

  type Ohana::Protocol::Response::OK
  status 'OK'

  prop 'content',      String, 'it worked out ok'
  prop 'content_type', String, 'String'

  def setup
    @json =<<-JSON
      {"status":"OK",
        "content": "it worked out ok" }
    JSON
    self.response = Ohana::Protocol::Response.parse(@json)
  end

  def test_content_type_process
    json =<<-JSON
      {"status":"OK",
        "content": {"name":"echo"},
        "content_type":"Process" }
    JSON
    p = Ohana::Protocol::Response.parse(json) 
    assert_equal 'Process', p.content_type
    assert_instance_of Ohana::Protocol::Process, p.content
  end

  def test_content_type_processes
    json =<<-JSON
      {"status":"OK",
        "content": [{"name":"echo"}, {"name":"sleeper"}],
        "content_type":"[Process]" }
    JSON
    p = Ohana::Protocol::Response.parse(json) 
    assert_equal '[Process]', p.content_type
    assert_instance_of Array, p.content
    assert_equal 2, p.content.count
    assert_instance_of Ohana::Protocol::Process, p.content.first
  end
end
