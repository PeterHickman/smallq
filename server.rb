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
      m = client.gets.chomp.split(' ', 3)

      case m[0]
      when 'ADD'
        i = qm.add(m[1], m[2])
        both(client, 'ADD', "OK #{i}")
      when 'GET'
        r = qm.get(m[1])
        if r
          both(client, 'GET', "OK #{r[:id]} #{r[:message]}")
        else
          both(client, 'GET', 'ERROR QUEUE EMPTY')
        end
      when 'STATS'
        qm.stats.each do |l|
          both(client, 'STATS', l.join(' '))
        end
      else
        both(client, 'STATS', 'ERROR UNKNOWN COMMAND')
      end
    rescue => e
      both(client, 'ERROR', "ERROR #{e}")
    end

    client.close
  end
end
