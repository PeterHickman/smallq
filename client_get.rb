#!/usr/bin/env ruby

$LOAD_PATH << './lib'

require 'smallq/client'
require 'smallq/config'

QUEUE = 'test_queue'

filename = ARGV[0]

config = Smallq::Config.load(filename)

c = Smallq::Client.new(config['server'])

count = 0

t1 = Time.now

x = c.get(QUEUE)

until x[:status] == 'ERROR'
  count += 1
  x = c.get(QUEUE)
end
c.quit

t2 = Time.now

puts "Read #{count} messages in #{t2 - t1} seconds"
puts "That is #{count.to_f / (t2 - t1)} per second"
