#!/usr/bin/env ruby
# encoding: UTF-8

$LOAD_PATH << './lib'

require 'smallq/client'
require 'test_helper'

c = Smallq::Client.new('localhost', 2000)

drain_queues(c)

puts 'Make sure the server is running'
puts '-------------------------------'

##
# Valid names
##

assert_doesnt_raise(Smallq::QueueNameInvalidError, 'Shortest valid name') do
  c.add('xx', 'My message')
end

assert_doesnt_raise(Smallq::QueueNameInvalidError, 'Longest valid name') do
  c.add('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'My message')
end

assert_doesnt_raise(Smallq::QueueNameInvalidError, 'All valid character types') do
  c.add('a-K_7.a', 'My message')
end

##
# Invalid names
##

assert_raises(Smallq::QueueNameInvalidError, 'Too short') do
  c.add('x', 'My message')
end

assert_raises(Smallq::QueueNameInvalidError, 'Blank') do
  c.add('', 'My message')
end

assert_raises(Smallq::QueueNameInvalidError, 'Too long') do
  c.add('ppppppppppppppppppppppppppppppp', 'My message')
end

assert_raises(Smallq::QueueNameInvalidError, 'Contains a space') do
  c.add('fr ed', 'My message')
end

assert_raises(Smallq::QueueNameInvalidError, 'Contains a tab') do
  c.add("fr\ted", 'My message')
end

assert_raises(Smallq::QueueNameInvalidError, 'Contains a new line') do
  c.add("fr\ned", 'My message')
end

assert_raises(Smallq::QueueNameInvalidError, 'Contains a return') do
  c.add("fr\red", 'My message')
end

assert_raises(Smallq::QueueNameInvalidError, 'Contains a form feed') do
  c.add("fr\fed", 'My message')
end

assert_raises(Smallq::QueueNameInvalidError, 'Contains a zero byte') do
  c.add("fr\0ed", 'My message')
end

assert_raises(Smallq::QueueNameInvalidError, 'Starts with a space') do
  c.add(' fred', 'My message')
end

assert_raises(Smallq::QueueNameInvalidError, 'Ends with a space') do
  c.add('fred ', 'My message')
end

assert_raises(Smallq::QueueNameInvalidError, 'Contains an invalid character') do
  c.add('fr^ed', 'My message')
end
