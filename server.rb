#!/usr/bin/env ruby

require 'socket'
require 'thread'

$LOAD_PATH << './lib'

require 'smallq/queue_manager'

def both(client, command, message)
  puts "#{command} #{message}"
  client.puts message
end

server = TCPServer.new('localhost', 2000)

qm = Smallq::QueueManager.new

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
        adds, gets, size, updated_at = qm.stats
        both(client, 'STATS', "OK #{adds} #{gets} #{size} #{updated_at}")
      else
        both(client, 'STATS', 'ERROR UNKNOWN COMMAND')
      end
    rescue => e
      both(client, 'ERROR', "ERROR #{e}")
    end

    client.close
  end
end
