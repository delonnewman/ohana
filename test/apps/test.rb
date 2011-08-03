require 'sinatra'
# require 'ohana/sinatra'
require 'json'

before do
  content_type 'application/json'
end

# channel '/say'  { }
post '/channel/say' do
  msg = params[:message]
  puts msg
  case msg
  when 'miredita' then puts "Are you Albanian?"
  when 'hola'     then puts "Do you speak Spanish?"
  when 'hello'    then puts "Oh, you speak English"
  else
    puts "I'm sorry, I don't know what you're talking about."
  end
  
  "OK".to_json
end

# automatically generated
get '/process.json' do
  { :name => 'test',
    :version => 1,
    :channels => %w{ say },
    :root_uri => 'http://localhost:4567' }.to_json
end
