module Hyalite
  class EventDispatcher
    def initialize(&extract_events)
      @enabled = true
      @listener_bank = {}
      @extract_events = extract_events
      @event_queue = []
    end

    def enabled?
      @enabled
    end

    def enabled=(enabled)
      @enabled = enabled
    end

    def trap_bubbled_event(top_level_type, handler_base_name, element)
      return nil unless element

      element.on handler_base_name do |event|
        dispatch_event(top_level_type, event)
      end
    end

    def find_parent(node)
      node_id = Mount.node_id(node)
      root_id = InstanceHandles.root_id_from_node_id(node_id)
      container = Mount.container_for_id(root_id)
      Mount.find_first_hyalite_dom(container)
    end

    def handle_top_level(book_keeping)
      ancestor = Mount.find_first_hyalite_dom(book_keeping.event.target)
      while ancestor
        book_keeping.ancestors << ancestor
        ancestor = find_parent(ancestor)
      end

      book_keeping.ancestors.each do |top_level_target|
        top_level_target_id = Mount.node_id(top_level_target) || ''
        synthetic_events = @extract_events.call(
          book_keeping.top_level_type,
          top_level_target,
          top_level_target_id,
          book_keeping.event,
        ).flatten

        synthetic_events.each do |synthetic_event|
          synthetic_event.each_listener do |listener, dom_id|
            target = Mount.node(dom_id);
            listener.call(synthetic_event.event, target)
          end
        end
      end
    end

    def dispatch_event(top_level_type, event)
      return unless @enabled

      book_keeping = TopLevelCallbackBookKeeping.new(top_level_type, event)
      Hyalite.updates.batched_updates { handle_top_level(book_keeping) }
    end

    def put_listener(id, registration_name, listener)
      listeners = @listener_bank[registration_name] ||= {}
      listeners[id] = listener
    end

    def get_listener(id, registration_name)
      @listener_bank[registration_name].try {|listeners| listeners[id] }
    end

    def delete_listener(id, registration_name)
      if @listener_bank.has_key? registration_name
        yield(id, name)
        @listener_bank[registration_name].delete(id)
      end
    end

    def delete_all_listeners(id, &block)
      @listener_bank.each do |registration_name, bank|
        next unless bank[id]
        yield(id, registration_name) if block_given?
        bank.delete(id)
      end
    end

    class TopLevelCallbackBookKeeping
      attr_reader :event, :top_level_type, :ancestors

      def initialize(top_level_type, event)
        @top_level_type = top_level_type
        @event = event
        @ancestors = []
      end
    end
  end
end
