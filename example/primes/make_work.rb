#!/usr/bin/env ruby
# encoding: UTF-8

require 'logger'

$LOAD_PATH << './lib'

QUEUE_NAME = 'available'
MINIMUM_QUEUE_SIZE = 20
ALLOCATION_MULTIPLIER = 2
STEP = 999_999

require 'smallq/client'

def queue_details(c)
  r = c.stats

  c.stats.each do |q|
    return q if q[:queue_name] == QUEUE_NAME
  end

  {}
end

limit = ARGV[0]
if limit
  limit = limit.to_i
else
  limit = 30
end

c = Smallq::Client.new('localhost', 2000)

logger = Logger.new(STDERR)

logger.info "Work limit is #{limit}"

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
