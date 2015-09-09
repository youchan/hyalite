require 'hyalite/transaction'

module Hyalite
  class ReconcileTransaction < Transaction
    def initialize
      @mount_ready_wrapper = MountReadyWrapper.new
      super [ @mount_ready_wrapper ]
    end

    def mount_ready
      @mount_ready_wrapper.queue
    end

    class MountReadyWrapper
      include TransactionWrapper

      attr_reader :queue

      def initialize
        @queue = CallbackQueue.new
      end

      def close
        @queue.notify_all
      end
    end
  end
end
