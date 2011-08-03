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
end

class TestRequest < Test::Unit::TestCase
  def setup
    @method  = 'SEND'
    @content = { 
      :process => 'test',
      :channel => 'say',
      :content => "hello it's #{Time.now} from TestRequest"
    }
    @req = Ohana::Request.parse({ :method => @method, :content => @content }.to_json)
  end

  def test_method
    assert_equal @method, @req.method, "method should be #{@method}"
  end

  def test_content
    assert_equal @content[:process], @req.content.process 
    assert_equal @content[:channel], @req.content.channel 
    assert_equal @content[:content], @req.content.content 
  end

  def test_dispatch
    p d = @req.dispatch
    assert d
  end
end
