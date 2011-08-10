require File.expand_path(File.join(File.dirname(__FILE__), '../../test/protocol/helpers'))
require 'json'

module TestDSL
  def test_response_parse
    if @res
	    assert_nothing_raised do
	      Ohana::Protocol::Response.parse(@res.to_json)
	    end
    end
  end

  def test_request_parse
    if @req
	    assert_nothing_raised do
	      Ohana::Protocol::Request.parse(@req.to_json)
	    end
    end
  end
end

class TestAwaitDSL < Test::Unit::TestCase
  include ResponseTestHelpers
  include TestDSL

  type   Ohana::Protocol::Response::Await
  status 'AWAIT'

  prop 'to',      Ohana::Protocol::Location
  prop 'from',    Ohana::Protocol::Location
  prop 'channel', String, 'say'

  def setup
    @res = await('say', from('sleeper/sleep'), to('echo/say'))
  end
end

class TestNoResponseDSL < Test::Unit::TestCase
  include ResponseTestHelpers
  include TestDSL

  type   Ohana::Protocol::Response::NoResponse
  status 'NORESPONSE'

  prop 'to',      Ohana::Protocol::Location
  prop 'from',    Ohana::Protocol::Location

  def setup
    @res = no_response(from('sleeper/sleep'), to('echo/say'))
  end
end

class ErrorDSL < Test::Unit::TestCase
  include ResponseTestHelpers
  include TestDSL

  type   Ohana::Protocol::Response::Error
  status 'ERROR'

  prop 'to',      Ohana::Protocol::Location
  prop 'from',    Ohana::Protocol::Location
  prop 'type',    String, 'PROCESS_ERROR'
  prop 'message', String, 'this is an error'

  def setup
    @res = process_error("this is an error", from('sleeper/sleep'), to('echo/say'))
  end

  def test_server_error
    @res = server_error("this is a server error")
    assert_equal "this is a server error", @res.message
  end
end

class TestOKDSL < Test::Unit::TestCase
  include ResponseTestHelpers
  include TestDSL

  type   Ohana::Protocol::Response::OK
  status 'OK'

  prop 'content',      String, 'it went ok'
  prop 'content_type', String, 'String'

  def setup
    @res = ok('it went ok')
  end
end

class TestSendDSL < Test::Unit::TestCase
  include RequestTestHelpers
  include TestDSL

  type   Ohana::Protocol::Request::Send
  method 'SEND'

  prop 'to',       Ohana::Protocol::Location
  prop 'from',     Ohana::Protocol::Location
  prop 'reply_to', Ohana::Protocol::Location
  prop 'message',  String, 'Miredita!'

  def setup
    @req = send_msg('Miredita!', from('echo/say'), to('sleeper/sleep'), reply_to('sleeper/say'))
  end
end

class TestListDSL < Test::Unit::TestCase
  include RequestTestHelpers
  include TestDSL

  type   Ohana::Protocol::Request::List
  method 'LIST'

  def setup
    @req = list
  end
end

class TestAddDSL < Test::Unit::TestCase
  include RequestTestHelpers
  include TestDSL

  type   Ohana::Protocol::Request::Add
  method 'ADD'

  prop 'name', String, 'echo'
  prop 'type', String, 'RESTful'
  prop 'uri',  String, 'http://localhost:4567/process.json'

  def setup
    @req = add('echo', 'RESTful', 'uri' => 'http://localhost:4567/process.json')
  end
end
