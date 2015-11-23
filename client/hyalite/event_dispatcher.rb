module Hyalite
  class EventDispatcher
    def initialize(&extract_event)
      @enabled = true
      @listener_bank = {}
      @extract_event = extract_event
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
        synthetic_event = @extract_event.call(
          book_keeping.top_level_type,
          top_level_target_id,
          book_keeping.event,
        )

        synthetic_event.each_listener do |listener, dom_id|
          target = Mount.node(dom_id);
          listener.call(synthetic_event.event, target)
        end
      end
    end

    def dispatch_event(top_level_type, event)
      return unless @enabled

      book_keeping = TopLevelCallbackBookKeeping.new(top_level_type, event)
      Hyalite.updates.batched_updates { handle_top_level(book_keeping) }
    end

    def put_listener(id, name, listener)
      listeners = @listener_bank[name] ||= {}
      listeners[id] = listener
    end

    def get_listener(id, name)
      @listener_bank[name].try {|bank| bank[id] }
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