module Hyalite
  class UpdateQueue
    class << self
      def is_mounted(public_instance)
        internal_instance = Hyalite.instance_map[public_instance]
        if internal_instance
          !!internal_instance.rendered_component
        else
          false
        end
      end

      def enqueue_callback(public_instance, &block)
        internal_instance = Hyalite.instance_map[public_instance]
        return nil unless internal_instance

        internal_instance.pending_callbacks ||= []
        internal_instance.pending_callbacks << block
        enqueueUpdate(internal_instance);
      end

      def enqueue_set_state(public_instance, partial_state)
        internal_instance = Hyalite.instance_map[public_instance]

        return unless internal_instance

        queue = internal_instance.pending_state_queue || (internal_instance.pending_state_queue = [])
        queue.push(partial_state)

        enqueue_update(internal_instance);
      end

      def enqueue_update(internal_instance)
        Hyalite.updates.enqueue_update(internal_instance)
      end
    end
  end
end
