require 'process'
require 'dispatcher'

module Ohana
  class Messenger < Process
    reciever :preforker

    receive :route do |msg|
      Dispatcher.dispatch(msg)
    end
  end
end
