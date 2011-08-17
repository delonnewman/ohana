class Process
  @@callbacks = {}
  def self.channels
    @@callbacks.keys
  end

  def self.receive(channel, &block)
    @@callbacks[channel] ||= {}
    @@callbacks[channel][:receive] = block
  end

  def self.pipe(channel, &block)
    @@callbacks[channel] ||= {}
    @@callbacks[channel][:pipe] = block
  end

  def receive(channel, message)
    @@callbacks[channel][:receive].call(message)
  end

  def pipe(channel, message)
    @@callbacks[channel][:pipe].call(message)
  end
end

class Messenger < Process
  def initialize
    @queue = Queue.instance
  end

  receive :route do |msg|
    Queue.push(msg)
  end

  pipe :route do
    Dispatcher.dispatch(@queue.pop) unless @queue.empty?
  end
end

class Dispatcher

end
