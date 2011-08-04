require 'sinatra'
require 'socket'

get '/:greeting' do
  sock = TCPSocket.new('localhost', 3141)
end
