#!/usr/bin/env ruby

require 'yaml'

$LOAD_PATH << './lib'

require 'smallq/server'
require 'smallq/config'
require 'smallq/logger'

filename = ARGV[0]

config = Smallq::Config.load(filename)

logger = Smallq::Logger.new(config['logger'])

s = Smallq::Server.new(config['server'], logger)
s.run
