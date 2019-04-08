#!/usr/bin/env ruby
# encoding: UTF-8

require 'logger'

$LOAD_PATH << './lib'

QUEUE_NAME = 'available'
MINIMUM_QUEUE_SIZE = 20
ALLOCATION_MULTIPLIER = 2
STEP = 999_999

require 'smallq/client'
require 'smallq/config'

def queue_details(c)
  r = c.stats

  c.stats.each do |q|
    return q if q[:queue_name] == QUEUE_NAME
  end

  {}
end

limit = ARGV[1]
if limit
  limit = limit.to_i
else
  limit = 30
end

filename = ARGV[0]

config = Smallq::Config.load(filename)

logger = Logger.new(STDERR)

logger.info "Work limit is #{limit}"

c = Smallq::Client.new(config['server'])

f = 1

loop do
  d = queue_details(c)

  size = d[:size] || 0

  logger.info "Queue #{QUEUE_NAME} size = #{size}"

  if size < MINIMUM_QUEUE_SIZE
    logger.info "Adding #{MINIMUM_QUEUE_SIZE * ALLOCATION_MULTIPLIER} new items"

    (MINIMUM_QUEUE_SIZE * ALLOCATION_MULTIPLIER).times do
      t = f + STEP
      c.add(QUEUE_NAME, "#{f} #{t}")
      f = t + 1
    end
  end

  d = queue_details(c)

  if d[:adds] > limit
    logger.info 'Work limit reached'
    break
  end
  sleep 60
end
