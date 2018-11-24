#!/usr/bin/env ruby

$LOAD_PATH << './lib'

require 'smallq/client'

number_of_messages = ARGV[0].to_i

TEST_MESSAGE = 'Test message'
QUEUE = 'test_queue'

c = Smallq::Client.new('localhost', 2000)

t1 = Time.now

number_of_messages.times do
  c.add(QUEUE, TEST_MESSAGE)
end

t2 = Time.now

puts "Sent #{number_of_messages} messages in #{t2 - t1} seconds"
puts "That is #{number_of_messages.to_f / (t2 - t1)} per second"
