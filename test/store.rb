require 'test/unit'

$lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require "#{$lib}/ohana"
require "#{$lib}/process"
require 'json'

class TestStore < Test::Unit::TestCase
  def setup
    @name = 'test'
    @uri  = 'http://localhost:4567/process.json'
    @p = Ohana::Process::RESTful.create(:name => @name, :spec_uri => @uri)
  end

  def teardown
    @p.destroy
  end

  def test_create
    assert_instance_of Ohana::Process::RESTful, @p
  end

  def test_fetch
    @p = Ohana::Process.fetch(@name)
    assert_equal @name, @p.name
    assert_equal @uri, @p.spec_uri
  end

  def test_spec
    assert_equal @name, @p.spec.name
    assert_equal %w{ say }, @p.channels
  end
end
