require 'hyalite/transaction'
require 'hyalite/browser_event'

module Hyalite
  class ReconcileTransaction < Transaction
    def initialize
      @mount_ready_wrapper = MountReadyWrapper.new
      super [ @mount_ready_wrapper, EventSuppressionWrapper.new ]
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

    class EventSuppressionWrapper
      include TransactionWrapper

      def initialize
        @previous_enabled = BrowserEvent.enabled?
        BrowserEvent.enabled = false
      end

      def close
        BrowserEvent.enabled = @previous_enabled
      end
    end
  end
end
