require 'socket'
require 'thread'

module Smallq
  class Server
    MESSAGE_ID=0
    MESSAGE_BODY=1

    def initialize(config, logger, qm)
      @host          = config['host']
      @port          = config['port']
      @cleanup_every = config['cleanup_every']
      @idle_for      = config['idle_for']

      @logger = logger

      @qm = qm

      @connections = 0
      @connections_mutex = Mutex.new
    end

    def run
      server = TCPServer.new(@host, @port)

      @logger.log('SERVER', 'Server starting up')

      Thread.start do
        loop do
          @qm.house_keeping(@idle_for)
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
                i = @qm.add(m[1], m[2])
                client.puts "OK #{i}"
              when 'GET'
                r = @qm.get(m[1])
                if r
                  client.puts "OK #{r[MESSAGE_ID]} #{r[MESSAGE_BODY]}"
                else
                  client.puts 'ERROR QUEUE EMPTY'
                end
              when 'STATS'
                @qm.stats.each do |l|
                  client.puts l.join(' ')
                end
                client.puts 'OK'
              when 'QUIT'
                break
              else
                client.puts 'ERROR UNKNOWN COMMAND'
              end
            rescue => e
              client.puts "ERROR #{e}"
              e.backtrace.each { |line| puts line }
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
