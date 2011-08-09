require File.expand_path(File.join(File.dirname(__FILE__), '../../test/protocol/helpers'))

class TestAwait < Test::Unit::TestCase
  include ResponseTestHelpers

  type   Ohana::Protocol::Response::Await
  status 'AWAIT'

  prop 'to',      Ohana::Protocol::Location
  prop 'from',    Ohana::Protocol::Location
  prop 'channel', String

  def setup
    @json = await('say', from('sleeper/sleep'), to('echo/say')).to_json

    self.response = Ohana::Protocol::Response.parse(@json)
  end

  def test_nil
    assert_not_nil Ohana::Protocol::Response.parse(@json)
  end

  def test_no_to
    json = { :status => 'AWAIT',
                :from => { :process => 'sleeper', :channel => 'sleep' },
                :channel => 'say' }.to_json


    assert_raise Ohana::Protocol::ResponseError do
      Ohana::Protocol::Response.parse(json)
    end
  end

  def test_no_from
    json = { :status => 'AWAIT',
                :to => { :process => 'sleeper', :channel => 'sleep' },
                :channel => 'say' }.to_json


    assert_raise Ohana::Protocol::ResponseError do
      Ohana::Protocol::Response.parse(json)
    end
  end

  def test_no_channel
    json = { :status => 'AWAIT',
                :to => { :process => 'echo', :channel => 'say' },
                :from => { :process => 'sleeper', :channel => 'sleep' } }.to_json

    assert_raise Ohana::Protocol::ResponseError do
      Ohana::Protocol::Response.parse(json)
    end
  end
end

class TestNoResponse < Test::Unit::TestCase
  include ResponseTestHelpers

  type Ohana::Protocol::Response::NoResponse
  status 'NORESPONSE'

  def setup
    @json = no_response(from('sleeper/sleep'), to('echo/say')).to_json

    self.response = Ohana::Protocol::Response.parse(@json)
  end
end

class TestError < Test::Unit::TestCase
  include ResponseTestHelpers

  type Ohana::Protocol::Response::Error
  status 'ERROR'

  prop 'message', String, 'this is an error'

  def setup
    @json = process_error('this is an error', from('sleeper/say'), to('echo/channel')).to_json

    self.response = Ohana::Protocol::Response.parse(@json)
  end

  def test_send_error_without_to
    @json = { :status => 'ERROR',
                :type => 'PROCESS_ERROR',
                :from => { :process => 'sleeper', :channel => 'sleep' },
                :message => 'this is an error' }.to_json

    assert_raise Ohana::Protocol::ResponseError do 
      Ohana::Protocol::Response.parse(@json)
    end
  end

  def test_send_error_without_from
    @json = { :status => 'ERROR',
                :type => 'PROCESS_ERROR',
                :to => { :process => 'echo', :channel => 'say' },
                :message => 'this is an error' }.to_json

    assert_raise Ohana::Protocol::ResponseError do 
      Ohana::Protocol::Response.parse(@json)
    end
  end

  def test_server_error_without_from_or_to
    @json = { :status => 'ERROR',
                :type => 'SERVER_ERROR',
                :message => 'this is an error' }.to_json

    assert_nothing_raised do
      Ohana::Protocol::Response.parse(@json)
    end
  end

  def test_with_invalid_error_type
    @json = { :status => 'ERROR',
                :type => 'INVALID_ERROR',
                :message => 'this is an error' }.to_json

    assert_raise Ohana::Protocol::ResponseError do
      Ohana::Protocol::Response.parse(@json)
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
    @json = ok('it worked out ok').to_json
    self.response = Ohana::Protocol::Response.parse(@json)
  end

  def test_content_type_process
    json = ok({:name => "echo"}, 'Process').to_json
    p    = Ohana::Protocol::Response.parse(json) 
    assert_equal 'Process', p.content_type
    assert_instance_of Ohana::Protocol::Process, p.content
  end

  def test_content_type_process
    json = ok([{:name => "echo"}, {:name => 'sleeper'}], '[Process]').to_json
    p    = Ohana::Protocol::Response.parse(json) 
    assert_equal '[Process]', p.content_type
    assert_instance_of Array, p.content
    assert_equal 2, p.content.count
    assert_instance_of Ohana::Protocol::Process, p.content.first
  end
end
