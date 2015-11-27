module Hyalite
  module Component
  attr_accessor :props, :state, :context, :refs

    def init_component(props, context, updator)
      @props = props
      @context = context
      @updator = updator
      @state = get_initial_state
      @refs = nil
    end

    def get_initial_state
      {}
    end

    def context_types
      {}
    end

    def child_context
      {}
    end

    def component_did_mount
    end

    def component_will_mount
    end

    def component_will_unmount
    end

    def component_will_update
    end

    def should_component_update(props, state, context)
      true
    end

    def set_state(states, &block)
      @updator.enqueue_set_state(self, states)
      if block_given?
        @updator.enqueue_callback(self, &block)
      end
    end

    def render
    end
  end

  class EmptyComponent
    include Component

    def self.empty_element
      @instance ||= ElementObject.new(EmptyComponent, nil, nil, nil, nil)
    end

    def render
      Hyalite.create_element("noscript", nil, nil)
    end
  end

  class TopLevelWrapper
    include Component

    def render
      @props
    end
  end
end
