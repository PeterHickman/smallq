module Smallq
  class QueueManager
    def initialize
      @message_id = Time.now.to_i
      @message_id_mutex = Mutex.new

      @q = []
      @q_mutex = Mutex.new
      @q_stats_adds = 0
      @q_stats_gets = 0
      @q_stats_updated_at = 0
    end

    def add(message)
      new_message_id = nil

      @message_id_mutex.synchronize do
        new_message_id = @message_id
        @message_id += 1
      end

      @q_mutex.synchronize do
        @q << { id: new_message_id, message: message }
      end
      @q_stats_adds += 1
      @q_stats_updated_at = Time.now.to_i

      new_message_id
    end

    def get
      r = nil

      @q_mutex.synchronize do
        if @q.any?
          r = @q.shift
          @q_stats_gets += 1
          @q_stats_updated_at = Time.now.to_i
        end
      end

      r
    end

    def stats
      return @q_stats_adds, @q_stats_gets, @q.size, @q_stats_updated_at
    end
  end
end
