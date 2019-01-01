module Smallq
  class QueueManager
    def initialize
      @message_id = Time.now.to_i
      @message_id_mutex = Mutex.new

      @queues = {}
    end

    def add(queue_name, message)
      new_message_id = nil

      @queues[queue_name] = new_queue unless @queues.key?(queue_name)

      ##
      # This mutex is to ensure that no one else accesses the named
      # queue when we update it
      ##
      @queues[queue_name][:mutex].synchronize do
        ##
        # This mutex ensures that the message id is unique across
        # all the queues
        ##
        @message_id_mutex.synchronize do
          new_message_id = @message_id
          @message_id += 1
        end

        @queues[queue_name][:data] << { id: new_message_id, message: message }
        @queues[queue_name][:adds] += 1
        @queues[queue_name][:last_used] = Time.now.to_i
      end

      new_message_id
    end

    def get(queue_name)
      return nil unless @queues.key?(queue_name)

      @queues[queue_name][:mutex].synchronize do
        if @queues[queue_name][:data].any?
          @queues[queue_name][:gets] += 1
          @queues[queue_name][:last_used] = Time.now.to_i
          return @queues[queue_name][:data].shift
        end
      end

      nil
    end

    def stats
      @queues.map do |queue_name, queue|
        [queue_name, queue[:adds], queue[:gets], queue[:data].size, queue[:last_used]]
      end
    end

    private

    def new_queue
      { mutex: Mutex.new, adds: 0, gets: 0, last_used: 0, data: [] }
    end
  end
end
