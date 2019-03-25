require 'socket'
require 'thread'

require 'smallq/queue_manager'

module Smallq
  class Server
    MESSAGE_ID=0
    MESSAGE_BODY=1

    def initialize(config, logger)
      @host          = config['host']
      @port          = config['port']
      @cleanup_every = config['cleanup_every']

      @logger = logger

      @connections = 0
      @connections_mutex = Mutex.new
    end

    def run
      server = TCPServer.new(@host, @port)

      qm = Smallq::QueueManager.new(@logger)

      @logger.log 'Starting up'

      Thread.start do 
        loop do
          qm.house_keeping
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

          @logger.log "Connection ##{this_connection} opened from #{client.peeraddr}"

          loop do
            begin
              s = client.gets
              next if s.nil?
              m = s.chomp.split(' ', 3)

              case m[0]
              when 'ADD'
                i = qm.add(m[1], m[2])
                both(client, 'ADD', "OK #{i}")
              when 'GET'
                r = qm.get(m[1])
                if r
                  both(client, 'GET', "OK #{r[MESSAGE_ID]} #{r[MESSAGE_BODY]}")
                else
                  both(client, 'GET', 'ERROR QUEUE EMPTY')
                end
              when 'STATS'
                qm.stats.each do |l|
                  both(client, 'STATS', l.join(' '))
                end
                both(client, 'STATS', 'OK')
              when 'QUIT'
                break
              else
                both(client, m[0], 'ERROR UNKNOWN COMMAND')
              end
            rescue => e
              both(client, 'ERROR', "ERROR #{e}")
              e.backtrace.each { |line| puts line }
              break
            end
          end

          @logger.log "Connection ##{this_connection} closed"

          client.close
        end
      end
    end

    private

    def both(client, command, message)
      puts "#{command} #{message}"
      client.puts message
    end
  end
end
