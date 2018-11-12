#!/usr/bin/env ruby
# encoding: UTF-8

$LOAD_PATH << './lib'

require 'smallq/client'

c = Smallq::Client.new('localhost', 2000)

puts 'Make sure the server is running'
puts '-------------------------------'

MESSAGES = %w(First Second Third Fourth Fifth Sixth Seveth Eight Ninth Tenth)

puts "Sending #{MESSAGES.size} messages"

MESSAGES.each do |message|
  r = c.add(message)

  if r.size != 2
    puts "Incorrect response: #{r.inspect}"
  end

  if r[0] != 'OK'
    puts "Not OK: #{r.inspect}"
  end

  if r[1] !~ /^\d+$/
    puts "Not OK: #{r.inspect}"
  end
end

puts 'All messages sent'

l = []

puts "Retrieving all #{MESSAGES.size} messages"

(1..MESSAGES.size).each do |count|
  r = c.get

  if r.size != 3
    puts "Incorrect response: #{r.inspect}"
  end

  if r[0] != 'OK'
    puts "Not OK: #{r.inspect}"
  end

  if r[1] !~ /^\d+$/
    puts "Not OK: #{r.inspect}"
  end

  l << r[2]
end

if MESSAGES != l
  puts 'Messages not returned in order'
  puts "Expected.: #{MESSAGES.inspect}"
  puts "Actual...: #{l.inspect}"
end

r = c.get

if r.size != 2
  puts "Incorrect response: #{r.inspect}"
end

if r[0] != 'ERROR'
  puts "Incorrect response: #{r.inspect}"
end

if r[1] != "QUEUE EMPTY"
  puts "Queue should be empty: #{r}"
end
