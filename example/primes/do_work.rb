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
require 'smallq/config'

filename = ARGV[0]

config = Smallq::Config.load(filename)

Smallq::Client.new(config['server']) do |c|
  loop do
    GC.start

    x = c.get(WORK_QUEUE)

    if x[:status] == 'OK'
      puts "Got work id##{x[:id]} #{x[:message]}"

      t1 = Time.now

      f, t = x[:message].split(/\s+/).map(&:to_i)
      p = Progress.new(f, t)
      (f..t).each do |i|
        p.draw
        p.inc
        if Prime.prime?(i)
          c.add(RESULTS_QUEUE, i.to_s)
        end
      end

      t2 = Time.now
    
      puts "Processed #{t - f + 1} values in #{t2 - t1} seconds"
    else
      puts 'Waiting for work'
      sleep 10
    end
  end
end
