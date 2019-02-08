#!/usr/bin/env ruby
# encoding: UTF-8

$LOAD_PATH << './lib'

QUEUE_NAME = 'general'

require 'smallq/client'
require 'smallq/config'

require 'test_helper'

filename = ARGV[0]

config = Smallq::Config.load(filename)

c = Smallq::Client.new(config['server'])

drain_queues(c)

puts 'Make sure the server is running'
puts '-------------------------------'

MESSAGES = %w(First Second Third Fourth Fifth Sixth Seveth Eight Ninth Tenth).freeze

MESSAGES.each do |message|
  r = c.add(QUEUE_NAME, message)

  assert_equal('OK', r[:status], 'Message added ok')
end

# Remove all but the last message
(MESSAGES.size - 1).times do
  c.get(QUEUE_NAME)
end

c.add(QUEUE_NAME, 'Eleventh')
l = []

# Retrieving the only 2 messages

2.times do
  r = c.get(QUEUE_NAME)

  assert_equal('OK', r[:status], 'Message retrieved ok')

  l << r[:message]
end

NEW_MESSAGES = %w(Tenth Eleventh).freeze

assert_equal(NEW_MESSAGES, l, 'Messages received in the order they were sent')

r = c.get(QUEUE_NAME)

assert_equal('ERROR', r[:status], 'Status was error')
assert_equal('QUEUE EMPTY', r[:message], 'The queue was empty')

puts c.stats
