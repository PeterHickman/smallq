#!/usr/bin/env ruby

$LOAD_PATH << './lib'

require 'smallq/client'
require 'smallq/config'

QUEUE = 'test_queue'

filename = ARGV[0]

config = Smallq::Config.load(filename)

count = 0

t1 = Time.now

c = Smallq::Client.new(config['server'])

x = c.get(QUEUE)

until x[:status] == 'ERROR'
  count += 1
  x = c.get64(QUEUE)
end

t2 = Time.now

puts "Read #{count} messages in #{t2 - t1} seconds"
puts "That is #{count.to_f / (t2 - t1)} per second"
