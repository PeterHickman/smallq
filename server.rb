#!/usr/bin/env ruby

require 'socket'
require 'thread'

class QueueManager
  def initialize
    @message_id = Time.now.to_i
    @message_id_mutex = Mutex.new

    @q = []
    @q_mutex = Mutex.new
    @q_stats_adds = 0
    @q_stats_gets = 0
  end

  def add(message)
    new_message_id = nil

    @message_id_mutex.synchronize do
      new_message_id = @message_id
      @message_id += 1
    end

    @q_mutex.synchronize do
      @q << { id: new_message_id, message: message }
    end
    @q_stats_adds += 1

    new_message_id
  end

  def get
    r = nil

    @q_mutex.synchronize do
      if @q.any?
        r = @q.shift
        @q_stats_gets += 1
      end
    end

    r
  end

  def stats
    return @q_stats_adds, @q_stats_gets, @q.size
  end
end

def both(client, command, message)
  puts "#{command} #{message}"
  client.puts message
end

server = TCPServer.new('localhost', 2000)

qm = QueueManager.new

puts 'Starting up'

loop do
  Thread.start(server.accept) do |client|
    begin
      m = client.gets.chomp

      if m.index('ADD ') == 0
        body = m[4..-1]
        i = qm.add(body)
        both(client, 'ADD', "OK #{i}")
      elsif m.index('GET') == 0
        r = qm.get
        if r
          both(client, 'GET', "OK #{r[:id]} #{r[:message]}")
        else
          both(client, 'GET', 'ERROR QUEUE EMPTY')
        end
      elsif m.index('STATS') == 0
        adds, gets, size = qm.stats
        both(client, 'STATS', "OK #{adds} #{gets} #{size}")
      else
        both(client, 'STATS', 'ERROR UNKNOWN COMMAND')
      end
    rescue => e
      both(client, 'ERROR', "ERROR #{e}")
    end

    client.close
  end
end
