module Hyalite
  module Reconciler

    SEPARATOR = '.';
    SUBSEPARATOR = ':';

    class << self
      def mount_component(internal_instance, root_id, mount_ready, context)
        markup = internal_instance.mount_component(root_id, mount_ready, context)
        if internal_instance.current_element.ref
          mount_ready.enqueue do
            internal_instanc.current_element.owner.attach_ref(internal_instanc.current_element.ref, instance)
          end
        end
        markup
      end

      def unmount_component(internal_instance)
        #ReactRef.detachRefs(internalInstance, internalInstance._currentElement);
        internal_instance.unmount_component
      end

      def receive_component(internal_instance, next_element, mount_ready, context)
        prev_element = internal_instance.current_element

        return if next_element == prev_element && next_element.owner

        # refs_changed = ReactRef.should_update_refs(prev_element, next_element)
        #
        # ReactRef.detach_refs(internal_instance, prev_element) if refs_changed

        internal_instance.receive_component(next_element, mount_ready, context)

        # transaction.enqueue(attach_refs, internal_instance) if refs_changed
      end

      def perform_update_if_necessary(internal_instance, mount_ready)
        internal_instance.perform_update_if_necessary(mount_ready)
      end

      def update_children(prev_children, next_nested_child_nodes, mount_ready, context)
        next_children = flatten_children(next_nested_child_nodes)
        return nil if next_children.nil? && prev_children.nil?

        next_children.each do |name, next_element|
          prev_child = prev_children && prev_children[name]
          prev_element = prev_child && prev_child.current_element
          if should_update_component(prev_element, next_element)
            receive_component(prev_child, next_element, mount_ready, context)
            next_children[name] = prev_child
          else
            if prev_child
              unmount_component(prev_child, name)
            end

            next_children[name] = instantiate_component(next_element, nil)
          end
        end

        prev_children.each do |name, prev_child|
          unless next_children && next_children.has_key?(name)
            unmount_component(prev_children[name])
          end
        end

        next_children;
      end

      def flatten_children(nested_child_nodes)
        res = []
        traverse_children(nested_child_nodes, "") do |name, child_node|
          res << [name, child_node]
        end

        res
      end

      def traverse_children(children, name_so_far)
        # children = nil if children == true || children == false

        # if children.nil? || children === String || children === Numeric || ElementObject.is_valid_element(children)
        #   name = name_so_far.blank? ? SEPARATOR + component_key(children, 0) : name_so_far
        #   yield [name, child_node]
        #   return 1
        # end

        case children
        when Array
          children.each_with_index do |child, i|
            next_name = (name_so_far.empty? ? SEPARATOR : name_so_far + SUBSEPARATOR) + component_key(child, i)
            traverse_children(child, next_name) {|n, c| yield [n, c] }
          end
        else
          name = name_so_far.empty? ? SEPARATOR + component_key(children, 0) : name_so_far
          yield [name, children]
        end
      end

      def component_key(component, index)
        return "$#{component.key}" if component && component.respond_to?(:key) # user provided key
        index.to_s
      end

      def should_update_component(prev_element, next_element)
        if prev_element && next_element
          if prev_element.is_a?(String) || prev_element.is_a?(Numeric)
            return (next_element.is_a?(String) || next_element.is_a?(Numeric))
          elsif prev_element.respond_to?(:key) && next_element.respond_to?(:key)
            return (prev_element.type == next_element.type)
          end
        end
        false
      end
    end

  end
end
