#!/usr/bin/env ruby

$LOAD_PATH << './lib'

require 'smallq/client'

TEST_MESSAGE = 'Test message'
QUEUE = 'test_queue'
NUMBER_OF_MESSAGES = 2_000_000

c = Smallq::Client.new('localhost', 2000)

t1 = Time.now

NUMBER_OF_MESSAGES.times do
  c.add(QUEUE, TEST_MESSAGE)
end

t2 = Time.now

puts "Sent #{NUMBER_OF_MESSAGES} messages in #{t2 - t1} seconds"
puts "That is #{NUMBER_OF_MESSAGES.to_f / (t2 - t1)} per second"
