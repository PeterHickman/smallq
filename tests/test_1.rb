#!/usr/bin/env ruby
# encoding: UTF-8

$LOAD_PATH << './lib'

require 'smallq/client'
require 'test_helper'

c = Smallq::Client.new('localhost', 2000)

puts 'Make sure the server is running'
puts '-------------------------------'

MESSAGES = %w(First Second Third Fourth Fifth Sixth Seveth Eight Ninth Tenth).freeze

puts "Sending #{MESSAGES.size} messages"

MESSAGES.each do |message|
  r = c.add(message)

  assert_equal('OK', r[:status])
end

puts 'All messages sent'

l = []

puts "Retrieving all #{MESSAGES.size} messages"

(1..MESSAGES.size).times do
  r = c.get

  assert_equal('OK', r[:status])

  l << r[:message]
end

assert_equal(MESSAGES, l)

r = c.get

assert_equal('ERROR', r[:status])
assert_equal('QUEUE EMPTY', r[:message])

puts c.stats
