#!/usr/bin/env ruby
# encoding: UTF-8

$LOAD_PATH << './lib'

RESULTS_QUEUE = 'results'

require 'smallq/client'
require 'smallq/config'

filename = ARGV[0]

config = Smallq::Config.load(filename)

c = Smallq::Client.new(config['server'])

loop do
  x = c.get(RESULTS_QUEUE)

  if x[:status] == 'OK'
    puts "#{x[:message]} is prime"
  else
    puts 'Sleeping'
    sleep 5
  end
end
