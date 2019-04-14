require 'socket'

module Smallq
  class Server
    MESSAGE_ID = 0
    MESSAGE_BODY = 1

    def initialize(config, logger, queue_manager)
      @host          = config['host']
      @port          = config['port']
      @cleanup_every = config['cleanup_every']
      @idle_for      = config['idle_for']

      @logger = logger

      @queue_manager = queue_manager

      @connections = 0
      @connections_mutex = Mutex.new
    end

    def run
      server = TCPServer.new(@host, @port)

      @logger.log('SERVER', 'Server starting up')

      Thread.start do
        loop do
          @queue_manager.house_keeping(@idle_for)
          sleep @cleanup_every
        end
      end

      loop do
        Thread.start(server.accept) do |client|
          this_connection = 0
          @connections_mutex.synchronize do
            this_connection = @connections
            @connections += 1
          end

          @logger.log('SERVER', "Connection ##{this_connection} opened from #{client.peeraddr}")

          loop do
            begin
              s = client.gets
              break if s.nil?

              m = s.chomp.split(' ', 3)

              case m[0]
              when 'ADD'
                i = @queue_manager.add(m[1], m[2])
                client.puts "OK #{i}"
              when 'GET'
                r = @queue_manager.get(m[1])
                if r
                  client.puts "OK #{r[MESSAGE_ID]} #{r[MESSAGE_BODY]}"
                else
                  client.puts 'ERROR QUEUE EMPTY'
                end
              when 'STATS'
                @queue_manager.stats.each do |l|
                  client.puts l.join(' ')
                end
                client.puts 'OK'
              when 'QUIT'
                break
              else
                client.puts 'ERROR UNKNOWN COMMAND'
              end
            rescue => e
              @logger.log('SERVER', "ERROR #{e}")
              e.backtrace.each { |line| @logger.log('SERVER', line) }
              break
            end
          end

          @logger.log('SERVER', "Connection ##{this_connection} closed")

          client.close
        end
      end
    end
  end
end
