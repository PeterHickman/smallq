#!/usr/bin/env ruby

require 'socket'
require 'thread'

semaphore = Mutex.new

server = TCPServer.new('localhost', 2000)

index = Time.now.to_i

qd = []
qi = []

puts "Starting up with index #{index}"

loop do
  Thread.start(server.accept) do |client|
    m = client.gets.chomp

    ##
    # Need to be defined so they can be used inside
    # the semaphore.synchronize { ... } blocks
    ##
    body = nil
    i = nil

    if m.index('ADD ') == 0
      body = m[4..-1]
      puts "Added #{index} [#{body}]"
      client.puts "OK #{index}"
      semaphore.synchronize {
        qd << body
        qi << index
        index += 1
      }
    elsif m.index('GET') == 0
      if qd.any?
        semaphore.synchronize {
          body = qd.shift
          i = qi.shift
        }
        puts "Popped #{i} #{body}"
        client.puts "OK #{i} #{body}"
      else
        puts 'ERROR QUEUE EMPTY'
        client.puts 'ERROR QUEUE EMPTY'
      end
    else
      puts 'ERROR UNKNOWN COMMAND'
      client.puts 'ERROR UNKNOWN COMMAND'
    end

    client.close
  end
end
