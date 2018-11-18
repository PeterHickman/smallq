require 'socket'

module Smallq
  class QueueNameInvalidError < StandardError
  end

  class Client
    QUEUE_NAME_REGEX = /\A[a-zA-Z0-9_\-\.]{2,30}\z/

    def initialize(hostname, port)
      @hostname = hostname
      @port = port
    end

    def add(queue_name, message)
      unless valid_queue_name(queue_name)
        raise QueueNameInvalidError
      end

      r = command("ADD #{queue_name} #{message}")

      x = r.first.chomp.split(' ', 2)

      { status: x[0], id: x[1].to_i }
    end

    def get(queue_name)
      unless valid_queue_name(queue_name)
        raise QueueNameInvalidError
      end

      r = command("GET #{queue_name}")

      x = r.first.chomp.split(' ', 3)

      if x[0] == 'OK'
        { status: x[0], id: x[1].to_i, message: x[2] }
      else
        { status: x[0], message: x[1..-1].join(' ') }
      end
    end

    def stats
      r = command('STATS')

      l = []

      r.each do |x|
        x = x.chomp.split(' ')

        l << { queue_name: x[0], adds: x[1].to_i, gets: x[2].to_i, size: x[3].to_i, last_used: x[4].to_i }
      end

      l
    end

    private

    def command(message)
      s = TCPSocket.open(@hostname, @port)

      l = []
      s.puts message
      while m = s.gets
        l << m
      end

      return l
    end

    def valid_queue_name(name)
      if name =~ QUEUE_NAME_REGEX
        true
      else
        false
      end
    end
  end
end
