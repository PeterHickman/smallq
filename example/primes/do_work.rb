#!/usr/bin/env ruby
# encoding: UTF-8

require 'prime'

class Progress
  def initialize(minimum, maximum)
    @minimum = minimum
    @maximum = maximum

    @size = @maximum - @minimum + 1
 	@current = 0
  end

  def draw
    print "Processing %.2f%% of %d to %d          \r" % [(@current.to_f / @size.to_f) * 100.0, @minimum, @maximum]
  end

  def inc
    @current += 1 unless @current == @size
  end
end

$LOAD_PATH << './lib'

WORK_QUEUE = 'available'
RESULTS_QUEUE = 'results'

require 'smallq/client'

c = Smallq::Client.new('localhost', 2000)

loop do
  GC.start

  x = c.get(WORK_QUEUE)

  if x[:status] == 'OK'
    puts "Got work id##{x[:id]} #{x[:message]}"

    f, t = x[:message].split(/\s+/).map(&:to_i)
    p = Progress.new(f, t)
    (f..t).each do |i|
      p.draw
      p.inc
      if Prime.prime?(i)
        c.add(RESULTS_QUEUE, i.to_s)
      end
    end
  else
    puts 'Waiting for work'
    sleep 10
  end
end
