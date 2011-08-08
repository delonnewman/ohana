require File.expand_path(File.join(File.dirname(__FILE__), '../../test/protocol/helpers'))

class TestAwait < Test::Unit::TestCase
  include ResponseTestHelpers

  type   Ohana::Protocol::Response::Await
  status 'AWAIT'

  prop 'to',      Ohana::Protocol::Location
  prop 'from',    Ohana::Protocol::Location
  prop 'channel', String

  def setup
    @json = { :status => 'AWAIT',
                :to => { :process => 'echo', :channel => 'say' },
                :from => { :process => 'sleeper', :channel => 'sleep' },
                :channel => 'say' }.to_json

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
    @json = { :status => 'NORESPONSE',
                :to => { :process => 'echo', :channel => 'say' },
                :from => { :process => 'sleeper', :channel => 'sleep' } }.to_json
    self.response = Ohana::Protocol::Response.parse(@json)
  end
end

class TestError < Test::Unit::TestCase
  include ResponseTestHelpers

  type Ohana::Protocol::Response::Error
  status 'ERROR'

  prop 'message', String, 'this is an error'

  def setup
    @json = { :status => 'ERROR',
                :to => { :process => 'echo', :channel => 'say' },
                :from => { :process => 'sleeper', :channel => 'sleep' },
                :message => 'this is an error' }.to_json
    self.response = Ohana::Protocol::Response.parse(@json)
  end
end
