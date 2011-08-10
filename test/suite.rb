require 'test/unit'

$:.unshift('.') unless $:.include?('.')

MiniTest::Unit.autorun

require 'test/protocol/basic'
require 'test/protocol/dsl'
require 'test/protocol/request'
require 'test/protocol/response'
require 'test/dispatch'
