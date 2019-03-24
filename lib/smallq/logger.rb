require 'logger'

module Smallq
  class Logger
    def initialize(config)
      @logger = ::Logger.new(STDERR)
    end

    def info(message)
      @logger.info message
    end
  end
end
