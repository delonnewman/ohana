require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'ohana', 'server', 'process'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'ohana', 'protocol'))

class TestProcess < Test::Unit::TestCase
  def test_add_restful
    assert_nothing_raised do
      @p = Ohana::Process.add(:name => "echo",
                              :type => "RESTful",
                              :uri  => 'http://localhost:4567/process.json')
    end
    assert_instance_of Ohana::Process::RESTful, @p
    @p.destroy
  end

  def test_fetch
    assert_equal nil, Ohana::Process.fetch('not_there')
    assert_nothing_raised do
      Ohana::Process.add(:name => "echo",
                                 :type => "RESTful",
                                 :uri  => 'http://localhost:4567/process.json')
    end
    assert_not_nil p = Ohana::Process.fetch('echo')
    assert_instance_of Ohana::Process::RESTful, p
  end
end
