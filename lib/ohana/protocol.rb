$:.unshift File.dirname(__FILE__)
require 'protocol/parser'
require 'protocol/basic'
require 'protocol/request'
require 'protocol/response'

# response statuses

def response status, args={}
  { :status => status }.merge(args)
end

def await channel
  response "AWAIT", :channel => channel
end

def no_response
  response "NORESPONSE"
end

def error type, msg
  response "ERROR", :type => type, :message => msg
end

def process_error msg
  error "PROCESS_ERROR", msg
end

def server_error msg
  error "SERVER_ERROR", msg
end

# requests, methods

def request method, args={}
  { :method => method }.merge(args)
end

def send_msg message, args
  request "SEND", args
end

def list
  request "LIST"
end

def add args
  request "ADD", args
end

def get process
  request "GET", :process => process
end

def remove process
  request "REMOVE", :process => process
end
