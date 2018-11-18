#!/usr/bin/env ruby

$LOAD_PATH << './lib'

require 'smallq/server'

s = Smallq::Server.new('localhost', 2000)
s.run
