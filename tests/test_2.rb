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

puts 'Remove all but the last message'
(MESSAGES.size - 1).times do
  c.get
end

c.add('Eleventh')
l = []

puts 'Retrieving the only 2 messages'

2.times do
  r = c.get

  assert_equal('OK', r[:status])

  l << r[:message]
end

NEW_MESSAGES = %w(Tenth Eleventh).freeze

assert_equal(NEW_MESSAGES, l)

r = c.get

assert_equal('ERROR', r[:status])
assert_equal('QUEUE EMPTY', r[:message])

puts c.stats
