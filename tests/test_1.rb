#!/usr/bin/env ruby
# encoding: UTF-8

$LOAD_PATH << './lib'

require 'smallq/client'
require 'test_helper'

c = Smallq::Client.new('localhost', 2000)

puts 'Make sure the server is running'
puts '-------------------------------'

MESSAGES = %w(First Second Third Fourth Fifth Sixth Seveth Eight Ninth Tenth).freeze

MESSAGES.each do |message|
  r = c.add(message)

  assert_equal('OK', r[:status], 'Message added ok')
end

l = []

MESSAGES.size.times do
  r = c.get

  assert_equal('OK', r[:status], 'Message retrieved ok')

  l << r[:message]
end

assert_equal(MESSAGES, l, 'Messages received in the order they were sent')

r = c.get

assert_equal('ERROR', r[:status], 'Status was error')
assert_equal('QUEUE EMPTY', r[:message], 'The queue was empty')

puts c.stats
