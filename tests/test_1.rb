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

l = []

MESSAGES.size.times do
  r = c.get(QUEUE_NAME)

  assert_equal('OK', r[:status], 'Message retrieved ok')

  l << r[:message]
end

assert_equal(MESSAGES, l, 'Messages received in the order they were sent')

r = c.get(QUEUE_NAME)

assert_equal('ERROR', r[:status], 'Status was error')
assert_equal('QUEUE EMPTY', r[:message], 'The queue was empty')

puts c.stats
