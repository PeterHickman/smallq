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

puts "GET"
loop do
  send(hostname, port, 'GET')
  sleep 1
end

