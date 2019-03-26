module Smallq
  class QueueManager
    QUEUE_MUTEX=0
    QUEUE_ADDS=1
    QUEUE_GETS=2
    QUEUE_LAST_USED=3
    QUEUE_DATA=4

    def initialize(logger)
      @logger = logger

      @message_id = Time.now.to_i
      @message_id_mutex = Mutex.new

      @queues = {}
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
        @logger.log "house_keeping queue [#{queue_name}] is deleted"
        @queues.delete(queue_name)
      end
    end
  end
end
