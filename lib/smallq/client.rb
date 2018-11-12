require 'socket'

module Smallq
  class Client
    def initialize(hostname, port, debug = false)
      @hostname = hostname
      @port = port
      @debug = debug
    end

    def add(message)
      r = command("ADD #{message}")

      ##
      # Returns two fields, the status ('OK') and the message id
      ##
      r.split(/\s+/, 2)
    end

    def get
      r = command('GET')

      x = r.split(/\s+/)

      status = x[0]

      if status == 'OK'
        ##
        # Returning the status, id and body
        ##
        return x
      else
        ##
        # An error, plus the message
        ##
        return status, x[1..-1].join(' ')
      end
    end

    private

    def command(message)
      s = TCPSocket.open(@hostname, @port)

      puts "DEBUG: #{message}" if @debug
      s.puts message
      r = s.gets
      puts "DEBUG: #{r}" if @debug
      r
    end
  end
end
