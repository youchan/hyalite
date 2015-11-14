require 'hyalite/update_queue'
require 'hyalite/reconciler'
require 'hyalite/internal_component'

module Hyalite
  class CompositeComponent
    include InternalComponent

    attr_reader :current_element, :rendered_component
    attr_accessor :top_level_wrapper, :pending_state_queue, :mount_order, :pending_callbacks

    @next_mount_id = 1

    def self.next_mount_id
      @next_mount_id += 1
    end

    def initialize(element)
      @element = element
      @current_element = @element
    end

    def mount_component(root_id, mount_ready, context)
      @context = context
      @mount_order = CompositeComponent.next_mount_id
      @root_node_id = root_id

      public_context = mask_context(@context)
      @instance = @current_element.type.new
      @instance.init_component(@current_element.props, public_context, UpdateQueue)

      Hyalite.instance_map[@instance] = self

      @rendered_component = Hyalite.instantiate_component(render_component(@instance))

      markup = Reconciler.mount_component(
        @rendered_component,
        root_id,
        mount_ready,
        context.merge(@instance.child_context)
      )

      mount_ready.enqueue { @instance.component_did_mount }

      markup
    end

    def perform_update_if_necessary(mount_ready)
      if @pending_element
        receive_component(
          this,
          @pendingElement || this._currentElement,
          mount_ready,
          this._context
        );
      end

      if @pending_state_queue.any? || @pending_force_update
        update_component(
          mount_ready,
          @current_element,
          @current_element,
          @context,
          @context)
      end
    end

    def public_instance
      @instance
    end

    def inspect
      "CompositeComponent: instance: #{@instance.inspect}"
    end

    private

    def render_component(instance)
      Hyalite.current_owner(self) do
        instance.render
      end
    end

    def mask_context(context)
      context.select {|k, v| @current_element.type.context_types.has_key? k }
    end

    def update_component(mount_ready, prev_parent_element, next_parent_element, prev_unmasked_context, next_unmasked_context)
      next_context = (@context == next_unmasked_context ? @instance.context : mask_context(next_unmasked_context))

      next_props = next_parent_element.props
      next_state = process_pending_state(next_props, next_context)

      should_update =
        @pending_force_update ||
        @instance.should_component_update(next_props, next_state, next_context)

      if should_update
        @pending_force_update = false
        perform_component_update(
          next_parent_element,
          next_props,
          next_state,
          next_context,
          mount_ready,
          next_unmasked_context
        )
      else
        @current_element = next_parent_element
        @context = next_unmasked_context
        @instance.props = next_props
        @instance.state = next_state
        @instance.context = next_context
      end
    end

    def receive_component(next_element, mount_ready, next_context)
      prev_element = @current_element
      prev_context = @context

      @pending_element = nil

      updateComponent(
        mount_ready,
        prev_element,
        next_element,
        prev_context,
        next_context
      )
    end

    def perform_component_update(next_element, next_props, next_state, next_context, mount_ready, unmasked_context)
      prev_props = @instance.props
      prev_state = @instance.state
      prev_context = @instance.context

      @instance.component_will_update(next_props, next_state, next_context)

      @current_element = next_element
      @context = unmasked_context
      @instance.props = next_props
      @instance.state = next_state
      @instance.context = next_context

      update_rendered_component(mount_ready, unmasked_context)

      mount_ready.enqueue do
        @instance.component_did_update(prev_props, prev_state, prev_context)
      end
    end

    def update_rendered_component(mount_ready, context)
      prev_component_instance = @rendered_component
      prev_rendered_element = prev_component_instance.current_element
      next_rendered_element = render_validated_component
      if Reconciler.should_update_component(prev_rendered_element, next_rendered_element)
        Reconciler.receive_component(
          prev_component_instance,
          next_rendered_element,
          mount_ready,
          context
        )
      else
        this_id = @root_node_id
        prev_component_id = prev_component_instance.root_node_id
        Reconciler.unmount_component(prev_component_instance)

        @rendered_component = Hyalite.instantiate_component(next_rendered_element)
        next_markup = Reconciler.mount_component(
          @rendered_component,
          this_id,
          mount_ready,
          context
        )
        replace_node_with_markup_by_id(prev_component_id, next_markup)
      end
    end


    def replace_node_with_markup_by_id(id, markup)
      node = Mount.node(id)
      node.replace(markup)
    end

    def render_validated_component
      Hyalite.current_owner(self) do
        @instance.render
      end
    end

    def process_pending_state(props, context)
      replace = @pending_replace_state;
      @pending_replace_state = false;

      return @instance.state unless @pending_state_queue

      next_state = replace ? @pending_state_queue.shift : @instance.state
      @pending_state_queue.each do |queue|
        next_state = queue.is_a?(Proc) ? queue.call(@instance, next_state, props, context) : queue
      end

      next_state
    end

  end
end
