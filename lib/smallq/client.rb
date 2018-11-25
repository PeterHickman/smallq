require 'socket'

module Smallq
  class QueueNameInvalidError < StandardError
  end

  class MessageInvalidError < StandardError
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

      unless validate_message(message)
        raise MessageInvalidError
      end

      r = command("ADD #{queue_name} #{message}")
      if r.nil?
        { status: 'ERROR', message: 'UNABLE TO CONNECT TO SERVER' }
      else
        x = r.first.chomp.split(' ', 2)

        { status: x[0], id: x[1].to_i }
      end
    end

    def get(queue_name)
      unless valid_queue_name(queue_name)
        raise QueueNameInvalidError
      end

      r = command("GET #{queue_name}")

      if r.nil?
        { status: 'ERROR', message: 'UNABLE TO CONNECT TO SERVER' }
      else
        x = r.first.chomp.split(' ', 3)

        if x[0] == 'OK'
          { status: x[0], id: x[1].to_i, message: x[2] }
        else
          { status: x[0], message: x[1..-1].join(' ') }
        end
      end
    end

    def stats
      l = []

      r = command('STATS')

      unless r.nil?
        r.each do |x|
          x = x.chomp.split(' ')

          l << { queue_name: x[0], adds: x[1].to_i, gets: x[2].to_i, size: x[3].to_i, last_used: x[4].to_i }
        end
      end

      l
    end

    private

    def command(message)
      GC.disable

      s = TCPSocket.open(@hostname, @port)
      tries = 3

      while tries != 0
        begin
          l = []
          s.puts message
          while m = s.gets
            l << m
          end
          tries = 0
        rescue => e
          tries -= 1
          return nil if tries == 0
          puts 'retry'
          sleep 1
        end
      end

      GC.enable

      return l
    end

    def valid_queue_name(name)
      if name =~ QUEUE_NAME_REGEX
        true
      else
        false
      end
    end

    def validate_message(message)
      if message.size == 0
        false
      elsif message.include?("\n")
        false
      elsif message.include?("\r")
        false
      elsif message.include?("\f")
        false
      elsif message.include?("\0")
        false
      else
        true
      end
    end
  end
end
