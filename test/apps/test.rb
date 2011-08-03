require 'sinatra'
# require 'ohana/sinatra'
require 'json'

before do
  content_type 'application/json'
end

# channel '/say'  { }
post '/channel/say' do
  puts params[:message]
  "OK".to_json
end

# automatically generated
get '/process.json' do
  { :name => 'test',
    :version => 1,
    :channels => %w{ say },
    :root_uri => 'http://localhost:4567' }.to_json
end
