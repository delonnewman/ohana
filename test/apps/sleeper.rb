require 'sinatra'
# require 'ohana/sinatra'
require 'json'

set :port, 4568

before do
  content_type 'application/json'
end

# channel '/say'  { }
post '/channel/sleep' do
  puts "sleeping for #{params[:message]} seconds"
  sleep params[:message].to_i

  { process: 'echo', channel: 'say', content: "I'm up! I'm up!" }.to_json
end

# automatically generated
get '/process.json' do
  { :name => 'sleeper',
    :version => 1,
    :channels => %w{ sleep },
    :root_uri => 'http://localhost:4568' }.to_json
end
