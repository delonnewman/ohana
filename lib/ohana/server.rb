require 'socket'

$:.unshift('.') unless $:.include?('.')
require File.join(File.dirname(__FILE__), 'protocol')
require 'server/log'
require 'server/dispatch'
require 'server/message_queue'

module Ohana
end
