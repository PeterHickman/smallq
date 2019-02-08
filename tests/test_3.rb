#!/usr/bin/env ruby
# encoding: UTF-8

$LOAD_PATH << './lib'

require 'smallq/client'
require 'smallq/config'

require 'test_helper'

filename = ARGV[0]

config = Smallq::Config.load(filename)

c = Smallq::Client.new(config['server'])

puts 'Make sure the server is running'
puts '-------------------------------'

##
# Valid names
##

assert_doesnt_raise('Shortest valid name') do
  c.add('xx', 'My message')
end

assert_doesnt_raise('Longest valid name') do
  c.add('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'My message')
end

assert_doesnt_raise('All valid character types') do
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

##
# Valid messages
##

assert_doesnt_raise('Valid message') do
  c.add('general', 'asdasdasd')
end

assert_doesnt_raise('Shortest message') do
  c.add('general', 'x')
end

##
# Invalid messaes
##

assert_raises(Smallq::MessageInvalidError, 'Empty message') do
  c.add('general', '')
end

assert_raises(Smallq::MessageInvalidError, 'Contains \n') do
  c.add('general', "fr\ned")
end

assert_raises(Smallq::MessageInvalidError, 'Contains \r') do
  c.add('general', "fr\red")
end

assert_raises(Smallq::MessageInvalidError, 'Contains \f') do
  c.add('general', "fr\fed")
end

assert_raises(Smallq::MessageInvalidError, 'Contains \0') do
  c.add('general', "fr\0ed")
end
