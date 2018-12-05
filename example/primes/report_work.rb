#!/usr/bin/env ruby
# encoding: UTF-8

$LOAD_PATH << './lib'

RESULTS_QUEUE = 'results'
CLEAN_UP = 100

require 'smallq/client'

c = Smallq::Client.new('localhost', 2000)

counter = 0

loop do
  x = c.get(RESULTS_QUEUE)

  counter += 1
  if counter == CLEAN_UP
    GC.start
    counter = 0
  end

  if x[:status] == 'OK'
    puts "#{x[:message]} is prime"
  else
    puts "Sleeping"
    GC.start
    sleep 5
  end
end
