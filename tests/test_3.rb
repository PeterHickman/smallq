#!/usr/bin/env ruby
# encoding: UTF-8

$LOAD_PATH << './lib'

require 'smallq/client'
require 'test_helper'

c = Smallq::Client.new('localhost', 2000)

puts 'Make sure the server is running'
puts '-------------------------------'

##
# Valid names
##

x = c.send(:valid_group_name, 'xx')
assert_equal(true, x, 'Shortest valid name')

x = c.send(:valid_group_name, 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
assert_equal(true, x, 'Longest valid name')

x = c.send(:valid_group_name, 'a-K_7.a')
assert_equal(true, x, 'All valid character types')

##
# Invalid names
##
x = c.send(:valid_group_name, 'x')
assert_equal(false, x, 'Too short')

x = c.send(:valid_group_name, '')
assert_equal(false, x, 'Blank')

x = c.send(:valid_group_name, 'ppppppppppppppppppppppppppppppp')
assert_equal(false, x, 'Too long')

x = c.send(:valid_group_name, 'fr ed')
assert_equal(false, x, 'Contains a space')

x = c.send(:valid_group_name, "fr\ted")
assert_equal(false, x, 'Contains a tab')

x = c.send(:valid_group_name, "fr\ned")
assert_equal(false, x, 'Contains a new line')

x = c.send(:valid_group_name, "fr\red")
assert_equal(false, x, 'Contains a return')

x = c.send(:valid_group_name, "fr\fed")
assert_equal(false, x, 'Contains a form feed')

x = c.send(:valid_group_name, "fr\0ed")
assert_equal(false, x, 'Contains a zero byte')

x = c.send(:valid_group_name, ' fred')
assert_equal(false, x, 'Starts with a space')

x = c.send(:valid_group_name, 'fred ')
assert_equal(false, x, 'Ends with a space')

x = c.send(:valid_group_name, 'fr^ed')
assert_equal(false, x, 'Contains an invalid character')
