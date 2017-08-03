require 'hyalite/short_hand'

module Hyalite
  module Component
    TAGS = %w(
      a abbr address area article aside audio b base bdi bdo blockquote body br button button button button canvas caption
      cite code col colgroup command datalist dd del details dfn div dl dt em embed fieldset figcaption figure footer form
      h1 h2 h3 h4 h5 h6 head header hgroup hr html i iframe img input ins kbd keygen label legend li link map mark menu meta
      meter nav noscript object ol optgroup option output p param pre progress q rp rt ruby s samp script section select small
      source span strong style sub summary sup table tbody td textarea tfoot th thead time title tr track u ul var video wbr
    )

    def pp(obj)
      puts obj.inspect
    end

    attr_accessor :props, :context, :refs

    def init_component(props, context, updator)
      @props = props
      @context = context
      @updator = updator
      @state = State.new(self, updator, initial_state)
      @refs = nil
    end

    def self.included(klass)
      klass.instance_eval do
        define_singleton_method(:state) do |key, initial_value|
          (@initial_state ||= {})[key] = initial_value
        end

        define_singleton_method(:initial_state) { @initial_state || {} }

        define_singleton_method(:before_mount) do |&block|
          if block
            @before_mount = block
          else
            @before_mount
          end
        end

        define_singleton_method(:after_mount) do |&block|
          if block
            @after_mount = block
          else
            @after_mount
          end
        end

        define_singleton_method(:before_update) do |&block|
          if block
            @before_update = block
          else
            @before_update
          end
        end

        define_singleton_method(:after_update) do |&block|
          if block
            @after_update = block
          else
            @after_update
          end
        end
      end

      TAGS.each do |tag|
        define_method(tag) do |props, *children, &block|
          children << ChildrenRenderer.new.instance_eval(&block) if block
          Hyalite.create_element(tag, props, *children)
        end
      end

      klass.extend ClassMethods
    end

    class ChildrenRenderer
      def initialize
        @children = []
        TAGS.each do |tag|
          define_singleton_method(tag) do |props, *children, &block|
            @children << Hyalite.create_element(tag, props, *children)
            @children
          end
        end
      end
    end

    module ClassMethods
      def el(props, *children)
        Hyalite.create_element(self, props, *children)
      end
    end

    def initial_state
      self.class.initial_state
    end

    def state
      @state.to_h
    end

    def state=(state)
      @state.set(state)
    end

    def child_context
      {}
    end

    def component_will_mount
      self.instance_eval(&self.class.before_mount) if self.class.before_mount
    end

    def component_did_mount
      self.instance_eval(&self.class.after_mount) if self.class.after_mount
    end

    def component_will_update(props, state, context)
      self.instance_eval(&self.class.before_update) if self.class.before_update
    end

    def component_did_update(props, state, context)
      self.instance_eval(&self.class.after_update) if self.class.after_update
    end

    def should_component_update(props, state, context)
      true
    end

    def force_update(&block)
      @updator.enqueue_force_update(self);
      if block_given?
        @updator.enqueue_callback(self, &block)
      end
    end

    def set_state(states, &block)
      @updator.enqueue_set_state(self, states)
      if block_given?
        @updator.enqueue_callback(self, &block)
      end
    end

    def render
    end

    class State
      def initialize(component, updator, initial_state)
        @component = component
        @updator = updator
        @state = initial_state.clone
        initial_state.each do |key, value|
          define_singleton_method(key) do
            @state[key]
          end
          define_singleton_method(key + '=') do |value|
            @updator.enqueue_set_state(@component, key => value)
          end
        end
      end

      def [](key)
        @state[key]
      end

      def set(state)
        @state = state.clone
      end

      def to_h
        @state
      end
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