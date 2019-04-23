#!/usr/bin/env ruby

$LOAD_PATH << './lib'

require 'smallq/client'
require 'smallq/config'

QUEUE = 'test_queue'.freeze

filename = ARGV[0]
number_of_messages = ARGV[1].to_i

config = Smallq::Config.load(filename)

t1 = Time.now

client = Smallq::Client.new(config['server'])

(1..number_of_messages).each do |i|
  message = "Message #{i} from #{Process.pid}"

  puts message

  client.add64(QUEUE, message)
end

t2 = Time.now

STDERR.puts "Sent #{number_of_messages} messages in #{t2 - t1} seconds"
STDERR.puts "That is #{number_of_messages.to_f / (t2 - t1)} per second"
