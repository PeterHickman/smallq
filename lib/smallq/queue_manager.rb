require 'fileutils'

module Smallq
  class QueueManager
    QUEUE_MUTEX=0
    QUEUE_ADDS=1
    QUEUE_GETS=2
    QUEUE_LAST_USED=3
    QUEUE_DATA=4

    def initialize(config, logger)
      @logger = logger

      @message_id = Time.now.to_i
      @message_id_mutex = Mutex.new

      @queues = {}

      @journal_enabled = config['enabled']
      @journal_path    = config['path']
      @journal_every   = config['every']
      @journal_file    = nil

      setup_journal
    end

    def add(queue_name, message)
      new_message_id = nil

      @queues[queue_name] = [Mutex.new, 0, 0, 0, []] unless @queues.key?(queue_name)

      ##
      # This mutex is to ensure that no one else accesses the named
      # queue when we update it
      ##
      @queues[queue_name][QUEUE_MUTEX].synchronize do
        ##
        # This mutex ensures that the message id is unique across
        # all the queues when adding
        ##
        @message_id_mutex.synchronize do
          new_message_id = @message_id
          @message_id += 1
        end

        @queues[queue_name][QUEUE_DATA] << [new_message_id, message]
        @queues[queue_name][QUEUE_ADDS] += 1
        @queues[queue_name][QUEUE_LAST_USED] = Time.now.to_i
      end

      new_message_id
    end

    def get(queue_name)
      return nil unless @queues.key?(queue_name)

      @queues[queue_name][QUEUE_MUTEX].synchronize do
        if @queues[queue_name][QUEUE_DATA].any?
          @queues[queue_name][QUEUE_GETS] += 1
          @queues[queue_name][QUEUE_LAST_USED] = Time.now.to_i
          return @queues[queue_name][QUEUE_DATA].shift
        end
      end

      nil
    end

    def stats
      @queues.map do |queue_name, queue|
        [queue_name, queue[QUEUE_ADDS], queue[QUEUE_GETS], queue[QUEUE_DATA].size, queue[QUEUE_LAST_USED]]
      end
    end

    def house_keeping(idle_for)
      cutoff = Time.now.to_i - idle_for

      @queues.each do |queue_name, data|
        next if data[QUEUE_DATA].any?
        next if data[QUEUE_LAST_USED] > cutoff
        @logger.log('QMANAGER', "Queue [#{queue_name}] deleted. Empty for #{idle_for} seconds")
        @queues.delete(queue_name)
      end
    end

    private

    def setup_journal
      if @journal_enabled
        FileUtils.mkdir_p @journal_path unless File.directory?(@journal_path)

        @logger.log('QMANAGER', 'Read the journal files')

        # TODO: Read the existing snapshot and transactions here

        Thread.start do
          loop do
            sleep @journal_every
            take_snapshot
          end
        end

        ##
        # It's easier and cleaner to just take a new snapshot
        # and work from there rather than have all the parts
        # scattered
        ##
        take_snapshot
      else
        @logger.log('QMANAGER', 'Journalling is disabled')
      end
    end

    def take_snapshot
      @logger.log('QMANAGER', 'Make a snapshot and start a new journal')

      ts = Time.now.strftime('%Y%m%d-%H%M%S')

      filename = "#{@journal_path}/snapshot.#{ts}"

      f = File.new(filename, 'w')
      t1 = Time.now
      c = 0
      @queues.keys.each do |queue_name|
        @queues[queue_name][QUEUE_DATA].each do |message_id, message|
          c += 1
          f.puts "#{queue_name} #{message_id} #{message}"
        end
      end
      t2 = Time.now
      f.close
      @logger.log('QMANAGER', "Snapshot #{filename} written in #{t2 - t1} seconds. #{c} records")

      @journal_file.close unless @journal_file.nil?
      filename = "#{@journal_path}/transactions.#{ts}"
      @journal_file = File.new(filename, 'w')
      @journal_file.sync = true
    end
  end
end
