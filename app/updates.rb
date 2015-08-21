require_relative 'transaction'
require_relative 'callback_queue'
require_relative 'reconciler'
require_relative 'reconcile_transaction'

module Hyalite
  class Updates
    class NestedUpdate
      include TransactionWrapper

      def initialize(dirty_components)
        @dirty_components = dirty_components
      end

      def init
        @init_length = @dirty_components.length
      end

      def close
        if @dirty_components.length - @init_length > 0
          @dirty_components.shift(@init_length)
        else
          @dirty_components.clear
        end
      end
    end

    class UpdateQueueing
      include TransactionWrapper

      def initialize(queue)
        @queue = queue
      end

      def close
        @queue.notify_all
      end
    end

    attr_reader :reconcile_transaction

    def initialize
      @dirty_components = []

      @is_batching_updates = false

      @callback_queue = CallbackQueue.new
      @asap_callback_queue = CallbackQueue.new
      @asap_enqueued = false
      @reconcile_transaction = ReconcileTransaction.new

      @flush_transaction = Transaction.new([NestedUpdate.new(@dirty_components), UpdateQueueing.new(@callback_queue)])
    end

    def enqueue_update(component)
      unless @is_batching_updates
        batched_updates do
          enqueue_update(component)
        end
      end

      @dirty_components << component
    end

    def batched_updates
      already_batching_updates = @is_batching_updates

      @is_batching_updates = true

      if already_batching_updates
        yield
      else
        transaction = Transaction.new do
          flush_batched_updates
          @is_batching_updates = false
        end

        transaction.perform do
          yield
        end
      end
    end

    def flush_batched_updates
      while @dirty_components.length > 0 || @asap_enqueued
        if @dirty_components.length > 0
          @flush_transaction.perform do |transaction|
            run_batched_updates(transaction)
          end
        end

        if @asap_enqueued
          @asap_enqueued = false
          @asap_callback_queue.notify_all
          next
        end
      end
    end

    def run_batched_updates(transaction)
      @dirty_components.sort{|c1, c2| c1.mount_order <=> c2.mount_order}.each do |component|
        callbacks = component.pending_callbacks
        component.pending_callbacks = nil

        Reconciler.perform_update_if_necessary(component, @reconcile_transaction.mount_ready)

        if callbacks
          callbacks.each do |callback|
            @callback_queue.enqueue(callback)
          end
        end
      end
    end

    def mount_ready
      @reconcile_transaction.mount_ready
    end
  end

  def self.updates
    @updates ||= Updates.new
  end
end
