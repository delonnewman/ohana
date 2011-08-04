require 'sinatra'
# require 'ohana/sinatra'
require 'json'

before do
  content_type 'application/json'
end

# channel '/say'  { }
post '/channel/say' do
  content_type 'text/html'

  @msg = params[:message]
  puts @msg
  @questions = {
    'miredita' => "Are you Albanian?",
    'hola'     => "Do you speak Spanish?",
    'hello'    => "Oh, you speak English"
  }
  
  haml :say
end

# automatically generated
get '/process.json' do
  { :name => 'test',
    :version => 1,
    :channels => %w{ say },
    :root_uri => 'http://localhost:4567' }.to_json
end

__END__

@@ layout
%html
  = yield

@@ say
%h1= @msg

#message= @questions[@msg] || "I'm sorry I don't know what you're talking about"
