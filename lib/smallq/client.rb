require 'socket'
require 'base64'

module Smallq
  class QueueNameInvalidError < StandardError
  end

  class MessageInvalidError < StandardError
  end

  class Client
    QUEUE_NAME_REGEX = /\A[a-zA-Z0-9_\-\.]{2,30}\z/.freeze

    def initialize(config)
      @host = config['host']
      @port = config['port']

      @socket = connect
    end

    def add(queue_name, message)
      raise QueueNameInvalidError unless valid_queue_name(queue_name)

      raise MessageInvalidError unless validate_message(message)

      r = command("ADD #{queue_name} #{message}")
      if r.nil?
        { status: 'ERROR', message: 'UNABLE TO CONNECT TO SERVER' }
      else
        x = r.first.chomp.split(' ', 2)

        { status: x[0], id: x[1].to_i }
      end
    end

    def add64(queue_name, message)
      message64 = Base64.strict_encode64(message)
      add(queue_name, message64)
    end

    def get(queue_name)
      raise QueueNameInvalidError unless valid_queue_name(queue_name)

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

    def get64(queue_name)
      r = get(queue_name)

      r[:message] = Base64.strict_decode64(r[:message]) if r[:status] == 'OK'

      r
    end

    def stats
      l = []

      r = command('STATS')

      unless r.nil?
        r.each do |x|
          ##
          # Do not use .zero? here as .index can return nil
          # which .zero? does not respond to in the same way
          ##
          next if x.index('OK') == 0

          x = x.chomp.split(' ')

          l << { queue_name: x[0], adds: x[1].to_i, gets: x[2].to_i, size: x[3].to_i, last_used: x[4].to_i }
        end
      end

      l
    end

    private

    # def quit
    #   command('QUIT')
    # end

    def connect
      TCPSocket.open(@host, @port)
    end

    def command(message)
      l = []

      @socket.puts message

      while (m = @socket.gets)
        l << m

        ##
        # Do not use .zero? here as .index can return nil
        # which .zero? does not respond to in the same way
        ##
        break if m.index('OK') == 0
        break if m.index('ERROR') == 0
      end

      l
    end

    def valid_queue_name(name)
      if name =~ QUEUE_NAME_REGEX
        true
      else
        false
      end
    end

    def validate_message(message)
      if message.empty?
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
