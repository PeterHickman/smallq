require 'socket'

module Smallq
  class Client
    def initialize(hostname, port)
      @hostname = hostname
      @port = port
    end

    def add(message)
      r = command("ADD #{message}")

      x = r.chomp.split(' ', 2)

      { status: x[0], id: x[1].to_i }
    end

    def get
      r = command('GET')

      x = r.chomp.split(' ', 3)

      if x[0] == 'OK'
        { status: x[0], id: x[1].to_i, message: x[2] }
      else
        { status: x[0], message: x[1..-1].join(' ') }
      end
    end

    def stats
      r = command('STATS')

      x = r.chomp.split(' ')

      { status: x[0], adds: x[1].to_i, gets: x[2].to_i, size: x[3].to_i, last_used: x[4].to_i }
    end

    private

    def command(message)
      s = TCPSocket.open(@hostname, @port)

      s.puts message
      s.gets
    end
  end
end
