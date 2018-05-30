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

        define_singleton_method(:before_unmount) do |&block|
          if block
            @before_unmount = block
          else
            @before_unmount
          end
        end

        define_singleton_method(:after_unmount) do |&block|
          if block
            @after_unmount = block
          else
            @after_unmount
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
          if block
            Hyalite.create_element_hook do |hook_setter|
              renderer = ChildrenRenderer.new(self, hook_setter)
              renderer.instance_eval(&block)
              children += renderer.children.select{|el| el.is_a?(ElementObject) && el.parent.nil? }
            end
          end

          Hyalite.create_element(tag, props, *children)
        end
      end

      klass.extend ClassMethods
    end

    class ChildrenRenderer
      attr_reader :children

      def initialize(component, hook_setter)
        @component = component
        @children = []
        hook_setter.hook do |el|
          @children << el
        end
      end

      def method_missing(method_name, *args, &block)
        if @component.respond_to?(method_name, true)
          @component.send(method_name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @component.respond_to?(method_name, include_private) || super
      end
    end

    module ClassMethods
      def el(props, *children, &block)
        children << ChildrenRenderer.new(self).instance_eval(&block) if block
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

    def component_will_unmount
      self.instance_eval(&self.class.before_unmount) if self.class.before_unmount
    end

    def component_did_unmount
      self.instance_eval(&self.class.after_unmount) if self.class.after_unmount
    end

    def component_will_update(props, state, context)
      self.instance_exec(props, state, context, &self.class.before_update) if self.class.before_update
    end

    def component_did_update(props, state, context)
      self.instance_exec(props, state, context, &self.class.after_update) if self.class.after_update
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
    alias :update_state :set_state

    def method_missing(method_name, *args, &block)
      if @props.has_key?(method_name)
        @props[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @props.has_key?(method_name) || super
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
