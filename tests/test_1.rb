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

  if r[:status] != 'OK'
    puts "Not OK: #{r.inspect}"
  end

  if r[:message] !~ /^\d+$/
    puts "Not OK: #{r.inspect}"
  end
end

puts 'All messages sent'

l = []

puts "Retrieving all #{MESSAGES.size} messages"

(1..MESSAGES.size).each do |count|
  r = c.get

  if r[:status] != 'OK'
    puts "Not OK: #{r.inspect}"
  end

  if r[:id] !~ /^\d+$/
    puts "Not OK: #{r.inspect}"
  end

  l << r[:message]
end

if MESSAGES != l
  puts 'Messages not returned in order'
  puts "Expected.: #{MESSAGES.inspect}"
  puts "Actual...: #{l.inspect}"
end

r = c.get

if r[:status] != 'ERROR'
  puts "Incorrect response: #{r.inspect}"
end

if r[:message] != "QUEUE EMPTY"
  puts "Queue should be empty: #{r}"
end

puts c.stats
