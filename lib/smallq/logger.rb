module Smallq
  class Logger
    def initialize(config)
      @console = config['console']

      @pid = Process.pid

      @logger = nil
      if config['enabled'] == true
        @logger = File.open(config['path'], 'a')
        @logger.sync = true

        text = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%6N')} #{@pid} #{'=' * 40}"
        @logger.puts text
      end
    end

    def log(klass, message)
      return if @logger.nil? && !@console

      text = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%6N')} #{@pid} [#{klass}] #{message}"

      @logger.puts text if @logger
      puts text if @console
    end
  end
end
