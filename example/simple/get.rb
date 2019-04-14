#!/usr/bin/env ruby

$LOAD_PATH << './lib'

require 'smallq/client'
require 'smallq/config'

QUEUE = 'test_queue'.freeze

filename = ARGV[0]

config = Smallq::Config.load(filename)

count = 0

client = Smallq::Client.new(config['server'])

t1 = Time.now

x = client.get64(QUEUE)

until x[:status] == 'ERROR'
  puts x[:message]
  count += 1
  x = client.get64(QUEUE)
end

t2 = Time.now

STDERR.puts "Read #{count} messages in #{t2 - t1} seconds"
STDERR.puts "That is #{count.to_f / (t2 - t1)} per second"
