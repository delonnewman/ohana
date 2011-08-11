$:.unshift File.dirname(__FILE__)
require 'protocol/parser'
require 'protocol/basic'
require 'protocol/request'
require 'protocol/response'

# response statuses

def response status, args={}
  Ohana::Protocol::Response.dispatch({ 'status' => status }.merge(args))
end

def await channel, from, to
  response "AWAIT", { 'channel' => channel }.merge(from).merge(to)
end

def no_response from, to
  response "NORESPONSE", from.merge(to)
end

def error type, msg, args={}
  response "ERROR", { 'type' => type, 'message' => msg }.merge(args)
end

def process_error msg, from, to
  error "PROCESS_ERROR", msg, from.merge(to)
end

def server_error msg
  error "SERVER_ERROR", msg
end

def client_error msg
  error "CLIENT_ERROR", msg
end

def ok content, content_type='String'
  response "OK", 'content' => content, 'content_type' => content_type
end

# requests, methods

def request method, args={}
  Ohana::Protocol::Request.dispatch({ :method => method }.merge(args))
end

def send_msg message, from, to, reply_to={}
  request "SEND", { :message => message }.merge(from).merge(to).merge(reply_to)
end

def list
  request "LIST"
end

def add name, type, args
  request "ADD", { :name => name, :type => type }.merge(args)
end

def get process
  request "GET", :process => process
end

def remove process
  request "REMOVE", :process => process
end

def location(loc)
  p, c = loc.split('/')
  { :process => p, :channel => c  }
end

def from(loc)
  { :from => location(loc) }
end

def to(loc)
  { :to => location(loc) }
end

def reply_to(loc)
  { :reply_to => location(loc) }
end

def spec name, type, args
  { :spec => { :name => name, :type => type }.merge(args) }
end
