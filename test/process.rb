require 'test/unit'

$lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require "#{$lib}/ohana"
require "#{$lib}/process"
require 'json'

class TestProcess < Test::Unit::TestCase
  def test_io
    p Ohana::Process::IO.new.send_msg(STDOUT, "test")
  end
end
