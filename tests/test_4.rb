#!/usr/bin/env ruby
# encoding: UTF-8

$LOAD_PATH << './lib'

QUEUE_1 = 'tom'
QUEUE_2 = 'fred'

require 'smallq/client'
require 'test_helper'

c = Smallq::Client.new('localhost', 2000)

drain_queues(c)

puts 'Make sure the server is running'
puts '-------------------------------'

MESSAGES = %w(First Second Third Fourth Fifth Sixth Seveth Eight Ninth Tenth).freeze

MESSAGES.each do |message|
  r = c.add(QUEUE_1, message)

  assert_equal('OK', r[:status], 'Message added ok')

  r = c.add(QUEUE_2, message)

  assert_equal('OK', r[:status], 'Message added ok')
end

MESSAGES.size.times do
  r = c.get(QUEUE_1)

  assert_equal('OK', r[:status], 'Message retrieved ok')
end

r = c.stats
r.each do |q|
  if q[:queue_name] == QUEUE_1
    assert_equal(q[:size], 0, 'All messages read')
  elsif q[:queue_name] == QUEUE_2
    assert_equal(q[:size], 10, 'No messages read')
  end
end

