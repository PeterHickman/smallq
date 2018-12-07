#!/usr/bin/env ruby

$LOAD_PATH << './lib'

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

require 'smallq/client'

number_of_messages = ARGV[0].to_i

TEST_MESSAGE = 'Test message'
QUEUE = 'test_queue'

c = Smallq::Client.new('localhost', 2000)
p = Progress.new(1, number_of_messages)
t1 = Time.now

number_of_messages.times do
  c.add(QUEUE, TEST_MESSAGE)
  p.inc
  p.draw
end
puts

t2 = Time.now

puts "Sent #{number_of_messages} messages in #{t2 - t1} seconds"
puts "That is #{number_of_messages.to_f / (t2 - t1)} per second"
