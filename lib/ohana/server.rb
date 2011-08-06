require 'socket'
require 'logger'
require 'optparse'
require 'json'

require File.join(File.dirname(__FILE__), 'dispatch')

module Ohana
  HOST    = '127.0.0.1'.freeze
  PORT    = 3141
  WORKERS = 3

  class Server
    def self.log
      @@log ||= Logger.new('/tmp/ohana.log')
    end

    def self.exception(io, e)
      msg = "#{e.class}: #{e.message} \n#{e.backtrace.join("\n")}"
      log.error msg
	    begin
        io.puts msg
      rescue
        puts msg
      end
    end

    def self.options(args)
			options = { :daemonize => false }
      args.each do |arg|
        case arg
        when /-(d|daemonize)/ then options[:daemonize] = true
        end
      end
      options
    end

    def self.run(args=[])
      ::Process.daemon if options(args)[:daemonize]

      begin
        acceptor = Socket.new(:INET, :STREAM, 0)
        address  = Socket.pack_sockaddr_in(PORT, HOST)
        acceptor.bind(address)
        acceptor.listen(10)
      rescue Errno::EADDRINUSE => e
        puts "'#{HOST}:#{PORT}' is already in use"
        exit
      rescue
        raise $!
      end

      trap('EXIT') { acceptor.close }

      WORKERS.times do
        fork do
          trap('INT') { exit }

          puts "child #$$ accepting on shared socket (#{HOST}:#{PORT})"
		      loop {
		        sock, addr = acceptor.accept
            begin
		          req = Request.parse(sock.gets)
		          log.info("REQUEST: #{req.inspect}")
              puts "REQUEST: #{req.inspect}"
	            begin
	              d = req.dispatch
			          log.info("DISPATCHED: #{d.inspect}")
                sock.puts d
	            rescue => e
                exception sock, e
	            end
            rescue => e
              exception sock, e
            end
		        sock.close
            puts "child #$$: #{req.inspect}"
		      }
          exit
        end
      end

      trap('INT') { puts "\ngoing down..."; exit }

      ::Process.waitall
    end
  end

  class RequestError < RuntimeError; end
  class InvalidMethod < RequestError; end
  class MessageError < RequestError; end

  class Request
    attr_reader :method, :content

    @@methods = %w{ SEND ADD LIST }

    def initialize(method, content)
      @method  = method  || raise(RequestError, "method cannot be nil")
      @content = content

      unless @@methods.include?(@method)
        raise InvalidMethod, "'#{method}', #{@@methods.join(', ')} are valid."
      end

      if (method == 'SEND' or method == 'ADD') and content.nil?
        raise RequestError, "SEND and ADD requests must have content"
      end

      @content = Message.parse(content) if content && method == 'SEND'
    end

    def self.parse(str)
      req = JSON.parse(str)
      new(req['method'], req['content'])
    end

    def dispatch
      Dispatch.dispatch(self)
    end
  end

  class Message
    attr_reader :process, :channel, :content

    def initialize(process, channel, content)
      @process = process || raise(MessageError, "process cannot be nil")
      @channel = channel || raise(MessageError, "channel cannot be nil")
      @content = content || raise(MessageError, "content cannot be nil")
    end

    def self.parse(str)
      msg = if str.is_a?(Hash) then str else JSON.parse(str) end
      new(msg['process'], msg['channel'], msg['content'])
    end
  end
end
