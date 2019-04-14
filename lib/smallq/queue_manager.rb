require 'fileutils'

module Smallq
  class QueueManager
    QUEUE_MUTEX = 0
    QUEUE_ADDS = 1
    QUEUE_GETS = 2
    QUEUE_LAST_USED = 3
    QUEUE_DATA = 4

    ##
    # We need to make sure that there is no transaction in
    # progress so the wait_for_transaction method sleeps
    # until @transaction_in_progress is freed
    ##
    WAIT_FOR = 0.01

    def initialize(config, logger)
      @logger = logger

      @message_id = Time.now.to_i
      @message_id_mutex = Mutex.new

      @queues = {}

      @journal_enabled = config['enabled']
      @journal_path    = config['path']
      @journal_every   = config['every']
      @journal_file    = nil

      @transaction_write = Mutex.new
      @transaction_in_progress = false

      setup_journal
    end

    def add(queue_name, message)
      wait_for_transaction

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

      transaction("#{new_message_id} #{queue_name} #{message}")

      new_message_id
    end

    def get(queue_name)
      wait_for_transaction

      return nil unless @queues.key?(queue_name)

      @queues[queue_name][QUEUE_MUTEX].synchronize do
        if @queues[queue_name][QUEUE_DATA].any?
          @queues[queue_name][QUEUE_GETS] += 1
          @queues[queue_name][QUEUE_LAST_USED] = Time.now.to_i
          x = @queues[queue_name][QUEUE_DATA].shift
          transaction(x.first) # The message id
          return x
        end
      end

      nil
    end

    def stats
      wait_for_transaction

      @queues.map do |queue_name, queue|
        [queue_name, queue[QUEUE_ADDS], queue[QUEUE_GETS], queue[QUEUE_DATA].size, queue[QUEUE_LAST_USED]]
      end
    end

    def house_keeping(idle_for)
      cutoff = Time.now.to_i - idle_for

      @queues.each do |queue_name, data|
        next if data[QUEUE_DATA].any?
        next if data[QUEUE_LAST_USED] > cutoff

        @logger.log('HOUSEKEEPING', "Queue [#{queue_name}] deleted. Empty for #{idle_for} seconds")
        @queues.delete(queue_name)
      end

      old_files.each do |old_file|
        @logger.log('HOUSEKEEPING', "Removing old file #{old_file}")
        File.delete(old_file)
      end
    end

    def take_snapshot
      if @journal_enabled
        wait_for_transaction

        @transaction_write.synchronize do
          @transaction_in_progress = true

          @logger.log('SNAPSHOT', 'Make a snapshot and start a new journal')

          ts = Time.now.strftime('%Y%m%d-%H%M%S')

          filename = "#{@journal_path}/snapshot.#{ts}"

          f = File.new(filename, 'w')
          t1 = Time.now
          c = 0
          @queues.keys.each do |queue_name|
            @queues[queue_name][QUEUE_DATA].each do |message_id, message|
              c += 1
              f.puts "#{message_id} #{queue_name} #{message}"
            end
          end
          t2 = Time.now
          f.close
          @logger.log('SNAPSHOT', "Snapshot #{filename} written in #{t2 - t1} seconds. #{c} records")

          @journal_file.close unless @journal_file.nil?
          filename = "#{@journal_path}/transactions.#{ts}"
          @journal_file = File.new(filename, 'w')
          @journal_file.sync = true

          @transaction_in_progress = false
        end
      else
        @logger.log('QMANAGER', 'Journalling disabled')
      end
    end

    private

    def insert(queue_name, message_id, message)
      ##
      # This method is similar to add but is only called
      # by the reload_snapshot method to build the queues
      # from the journals. So it doesn't need to handle
      # mutexes or last accessed
      ##
      @queues[queue_name] = [Mutex.new, 0, 0, 0, []] unless @queues.key?(queue_name)

      @queues[queue_name][QUEUE_DATA] << [message_id, message]
    end

    def transaction(text)
      return unless @journal_enabled

      ##
      # Given that the application is threaded there exists
      # the not entirely impossible scenario that more than
      # one thread may call this at the same time. So as not
      # to completely mess up the transaction log we use
      # yet another mutux
      ##
      @transaction_write.synchronize do
        @transaction_in_progress = true

        @journal_file.puts text

        @transaction_in_progress = false
      end
    end

    def setup_journal
      if @journal_enabled
        FileUtils.mkdir_p @journal_path unless File.directory?(@journal_path)

        reload_snapshot

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

    def reload_snapshot
      @logger.log('QMANAGER', 'Read the journal files')

      snapshot, transactions, others = existing_snapshots

      data = {}
      missing_deletes = []

      if snapshot
        File.open(snapshot, 'r').each do |line|
          message_id, queue_name, message = line.chomp.split(' ')
          data[message_id] = [queue_name, message]
        end
      end

      if transactions
        File.open(transactions, 'r').each do |line|
          message_id, queue_name, message = line.chomp.split(' ')
          if queue_name.nil?
            if data.key?(message_id)
              data.delete(message_id)
            else
              missing_deletes << message_id
            end
          else
            data[message_id] = [queue_name, message]
          end
        end
      end

      if missing_deletes.any?
        missing_deletes.each do |message_id|
          data.delete(message_id)
        end
      end

      max_message_id = 0
      data.each do |message_id, x|
        message_id = message_id.to_i
        max_message_id = message_id if message_id > max_message_id
        queue_name, message = x
        insert(queue_name, message_id.to_i, message)
      end
      @message_id = max_message_id + 1 unless max_message_id.zero?

      @logger.log('QMANAGER', "New message id set to #{@message_id}")

      @queues.each do |_, x|
        x[QUEUE_LAST_USED] = Time.now.to_i
      end

      others.each do |old_file|
        @logger.log('QMANAGER', "Removing old file #{old_file}")
        File.delete(old_file)
      end
    end

    def existing_snapshots
      others = []

      x = Dir["#{@journal_path}/snapshot.*"].sort
      snapshot = x.pop
      others += x

      x = Dir["#{@journal_path}/transactions.*"].sort
      transactions = x.pop
      others += x

      [snapshot, transactions, others]
    end

    def old_files
      files = []

      x = Dir["#{@journal_path}/snapshot.*"].sort
      files += x[0..-3] if x.size > 2

      x = Dir["#{@journal_path}/transactions.*"].sort
      files += x[0..-3] if x.size > 2

      files
    end

    def wait_for_transaction
      sleep WAIT_FOR while @transaction_in_progress
    end
  end
end
