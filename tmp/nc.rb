#!/usr/bin/env ruby
require 'socket'
require 'stringio'

def connect(host, port)
  @socket = TCPSocket.open(host, port)
end

def forward_data(bufin, socket, &blk)
  bufout = StringIO.new
  while(true)
    IO.select([socket, bufin], nil, nil)
    begin
      while( (data = socket.recv_nonblock(100)) != "")
        #p data
        bufout.write_nonblock(data)
        #puts "BUFFER: #{@buffer.string.inspect}"
      end
      blk.call(bufout)
      #if no data is available rather than EAGAIN
      #that is EOF
      exit
    rescue Errno::EAGAIN
    end
    begin
      while( (data = bufin.read_nonblock(100)) != "")
        socket.write(data);
      end
    rescue Errno::EAGAIN
    rescue EOFError
      #STDIN uses EOFError
      #exit
    end
  end
end

def rw(req, &blk)
  sock = connect('localhost', 3141)
  bufout = StringIO.new
  sock.write(req);
  loop {
    p __LINE__
    IO.select([sock], nil, nil)
    p __LINE__
    # read from socket to output buffer
    begin
      p __LINE__
      p data = sock.recv_nonblock(100)
      while( data != "")
        p __LINE__
        bufout.write_nonblock(data)
      end
      blk.call(bufout) # execute callback
      break
    rescue Errno::EAGAIN => e
      puts "#{e.class}: #{e.message}"
    end # loop if EAGAIN
  }
end

req = '{"method":"SEND", "content":{"process":"echo", "channel":"say", "content":"miredita"}}'

#rw(req) { |b| puts b.string }
#forward_data($stdin, connect(*ARGV)) { |b| puts b.string }

require 'net/telnet'

s = Net::Telnet.new('Host' => 'localhost',
                    'Port' => 3141,
                    'Telnetmode' => false)

s.cmd(req) { |res| puts res }
