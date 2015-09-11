require 'hyalite/transaction'
require 'hyalite/adler32'
require 'hyalite/try'
require 'hyalite/transaction'
require 'hyalite/element'
require 'hyalite/component'
require 'hyalite/instance_handles'
require 'hyalite/updates'
require 'hyalite/composite_component'

module Hyalite
  module Mount
    ID_ATTR_NAME = 'data-hyalite-id'
    CHECKSUM_ATTR_NAME = 'data-react-checksum'

    @instances_by_root_id = {}
    @containers_by_root_id = {}
    @is_batching_updates = false

    class << self
      def render_subtree_into_container(parent_component, next_element, container)
        next_wrapped_element = ElementObject.new(TopLevelWrapper, nil, nil, nil, next_element)
        prev_component = @instances_by_root_id[root_id(container)]
        if prev_component
          prev_wrapped_element = prev_component.current_element
          prev_element = prev_wrapped_element.props;
          if Reconciler.should_update_component(prev_element, next_element)
            proc = block_given? ? Proc.new {|c| yield(c) } : nil
            return update_root_component(
              prev_component,
              next_wrapped_element,
              container,
              &proc
            ).rendered_component.public_instance
          else
            unmount_component_at_node(container)
          end
        end

        root_element = root_element_in_container(container)
        container_has_markup = root_element && is_rendered(root_element)
        should_reuse_markup = container_has_markup && prev_component.nil?

        component = render_new_root_component(
          next_wrapped_element,
          container,
          should_reuse_markup,
          parent_component ?
            parent_component.internal_instance.process_child_context(parent_component.internal_instance.context) :
            {}
        ).rendered_component.public_instance

        if block_given?
          yield component
        end

        component
      end

      def is_rendered(node)
        return false if node.node_type != Browser::DOM::Node::ELEMENT_NODE

        id = node_to_id(node)
        id ? id[0] == SEPARATOR : false
      end

      def render_new_root_component(next_element, container, should_reuse_markup, context)
        component_instance = Hyalite.instantiate_component(next_element, nil)
        root_id = register_component(component_instance, container)

        Hyalite.updates.batched_updates do
          mount_component_into_node(component_instance, root_id, container, should_reuse_markup, context)
        end

        component_instance
      end

      def register_component(next_component, container)
        #ReactBrowserEventEmitter.ensureScrollValueMonitoring();

        root_id = register_container(container)
        @instances_by_root_id[root_id] = next_component;
        root_id
      end

      def register_container(container)
        root_id = root_id(container)
        if root_id
          root_id = InstanceHandles.root_id_from_node_id(root_id)
        end

        unless root_id
          root_id = InstanceHandles.create_root_id
        end

        @containers_by_root_id[root_id] = container
        root_id
      end

      def mount_component_into_node(component_instance, root_id, container, should_reuse_markup, context)
        Hyalite.updates.reconcile_transaction.perform do |transaction|
          markup = Reconciler.mount_component(component_instance, root_id, transaction.mount_ready, context)
          component_instance.rendered_component.top_level_wrapper = component_instance
          mount_image_into_node(markup, container, should_reuse_markup)
        end
      end

      def mount_image_into_node(markup, container, should_reuse_markup)
        if should_reuse_markup
          root_element = root_element_in_container(container)
          checksum = Adler32.checksum markup
          checksum_attr = root_element.attr(CHECKSUM_ATTR_NAME)
          if checksum == checksum_attr
            return
          end

          root_element.remove_attr(CHECKSUM_ATTR_NAME)
          root_element.attr(CHECKSUM_ATTR_NAME, checksum)
        end

        container.inner_dom = markup
      end

      def root_element_in_container(container)
        if container.node_type == Browser::DOM::Node::DOCUMENT_NODE
          $document
        else
          container.child
        end
      end

      def root_id(container)
        root_element = root_element_in_container(container)
        root_element && node_to_id(root_element)
      end

      def node_cache
        @node_cache ||= {}
      end

      def node_to_id(node)
        id = internal_id(node)
        if id
          if node_cache.has_key?(id)
            cached = node_cache[id]
            if cached != node
              #raise "Mount: Two valid but unequal nodes with the same `#{ID_ATTR_NAME}`: #{id}"
              node_cache[id] = node
            end
          else
            node_cache[id] = node
          end
        end

        id
      end

      def internal_id(node)
        if node.node_type == Browser::DOM::Node::ELEMENT_NODE
          node.attr(ID_ATTR_NAME)
        end
      end

      def node_by_id(id)
        unless node_cache.has_key?(id) && is_valid(node_cache[id], id)
          node_cache[id] = find_component_root(@containers_by_root_id[id], id)
        end
        node_cache[id]
      end

      def is_valid(node, id)
        if node
          container = @containers_by_root_id[id]
          if container && contains_node(container, node)
            return true
          end
        end

        false
      end

      def find_component_root(ancestor_node, target_id)
        deepest_ancestor = find_deepest_cached_ancestor(target_id) || ancestor_node

        first_children = [ deepest_ancestor.child ]

        while first_children.length > 0
          child = first_children.shift

          while child
            child_id = node_to_id(child)
            if child_id
              if target_id == child_id
                return child
              elsif InstanceHandles.is_ancestor_id_of(child_id, target_id)
                first_children = [ child.child ]
              end
            else
              first_children.push(child.child)
            end

            child = child.next_sibling
          end
        end

        raise "can't find component_root"
      end

      def find_deepest_cached_ancestor(target_id)
        @deepest_node_so_far = nil
        InstanceHandles.traverse_ancestors(target_id) do |id|
          find_deepest_cached_ancestor_impl(id)
        end

        found_node = @deepest_node_so_far
        @deepest_node_so_far = nil
        found_node
      end

      def find_deepest_cached_ancestor_impl(ancestor_id)
        ancestor = node_cache[ancestor_id]
        if ancestor && is_valid(ancestor, ancestor_id)
          @deepest_node_so_far = ancestor;
        else
          false
        end
      end

      def contains_node(outer_node, inner_node)
        case
        when outer_node.nil? || inner_node.nil?
          false
        when outer_node == inner_node
          true
        when outer_node.node_type == Browser::DOM::Node::TEXT_NODE
          false
        else
          contains_node(outer_node, inner_node.parent)
        end
      end
    end
  end
end
