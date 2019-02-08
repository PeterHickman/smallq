#!/usr/bin/env ruby

require 'yaml'

$LOAD_PATH << './lib'

require 'smallq/server'
require 'smallq/config'

filename = ARGV[0]

config = Smallq::Config.load(filename)

s = Smallq::Server.new(config['server'])
s.run
