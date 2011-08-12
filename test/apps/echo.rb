require 'sinatra'
# require 'ohana/sinatra'
require 'json'

before do
  content_type 'application/json'
end

# channel '/say'  { }
post '/channel/say' do
  @msg = params[:message]
  puts @msg
  @questions = {
    'miredita' => "Are you Albanian?",
    'hola'     => "Do you speak Spanish?",
    'hello'    => "Oh, you speak English"
  }
  
  #reply @questions[@msg] || "I'm sorry I dont' know what you're talking about" 
  { process: 'echo', channel: 'say', content: (@questions[@msg] || "I'm sorry I don't know what you're talking about") }.to_json
end

# automatically generated
get '/process.json' do
  { :name => 'echo',
    :version => 1,
    :channels => %w{ say },
    :type     => 'RESTful',
    :root_uri => 'http://localhost:4567' }.to_json
end
