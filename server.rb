#!/usr/bin/env ruby

require 'yaml'

$LOAD_PATH << './lib'

require 'smallq/server'
require 'smallq/config'
require 'smallq/logger'
require 'smallq/queue_manager'

filename = ARGV[0]

c = Smallq::Config.load(filename)

l = Smallq::Logger.new(c['logger'])
q = Smallq::QueueManager.new(c['journal'], l)
s = Smallq::Server.new(c['server'], l, q)
s.run
