module Smallq
  class Logger
    def initialize(config)
      @console = config['console']

      @logger = nil
      if config['enabled'] == true
        @logger = File.open(config['path'], 'a')
        @logger.sync = true
      end
    end

    def log(message)
      return if @logger.nil? && !@console

      text = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%6N')} #{message}"

      @logger.puts text if @logger
      puts text if @console
    end
  end
end
