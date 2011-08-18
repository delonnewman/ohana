$:.unshift 'lib'
require 'ohana/receiver/preforker'

Ohana::Receiver::Preforker.new do |master, r|
  p master
  p r
end.run
