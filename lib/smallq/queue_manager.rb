module Smallq
  class QueueManager
    def initialize
      @message_id = Time.now.to_i
      @message_id_mutex = Mutex.new

      @q = {}
    end

    def add(queue_name, message)
      new_message_id = nil

      unless @q.key?(queue_name)
        @q[queue_name] = new_queue
      end

      @message_id_mutex.synchronize do
        new_message_id = @message_id
        @message_id += 1
      end

      @q[queue_name][:mutex].synchronize do
        @q[queue_name][:data] << { id: new_message_id, message: message }
        @q[queue_name][:adds] += 1
        @q[queue_name][:updated_at] = Time.now.to_i
      end

      new_message_id
    end

    def get(queue_name)
      return nil unless @q.key?(queue_name)

      r = nil

      @q[queue_name][:mutex].synchronize do
        if @q[queue_name][:data].any?
          r = @q[queue_name][:data].shift
          @q[queue_name][:gets] += 1
          @q[queue_name][:updated_at] = Time.now.to_i
        end
      end

      r
    end

    def stats
      l = []
      @q.each do |queue_name, queue|
        l << [queue_name, queue[:adds], queue[:gets], queue[:data].size, queue[:updated_at]]
      end
      l
    end

    private

    def new_queue
      { mutex: Mutex.new, adds: 0, gets: 0, updated_at: 0, data: [] }
    end
  end
end
