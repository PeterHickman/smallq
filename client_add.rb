#!/usr/bin/env ruby

require 'socket'

def send(hostname, port, message)
  s = TCPSocket.open(hostname, port)

  s.puts message

  m = s.gets
  puts m

  s.close
end

hostname = 'localhost'
port = 2000

puts "ADD"
(1..10).each do |i|
  send(hostname, port, "ADD FISH#{i}")
end
