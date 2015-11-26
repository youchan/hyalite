module Hyalite
  module MultiChildren
    def mount_children(nested_children, mount_ready, context)
      children = instantiate_children(nested_children, mount_ready, context)
      @rendered_children = children
      index = 0
      children.keys.map do |name|
        child = children[name]
        root_id = root_node_id + name
        mount_image = Reconciler.mount_component(children[name], root_id, mount_ready, context)
        child.mount_index = index
        index += 1
        mount_image
      end
    end

    def unmount_children
      if @rendered_children
        Reconciler.unmount_children(@rendered_children)
        @rendered_children = nil
      end
    end

    def update_children(next_nested_children, mount_ready, context)
      prev_children = @rendered_children
      next_children = Reconciler.update_children(prev_children, next_nested_children, mount_ready, context)
      @rendered_children = next_children
      if next_children.nil? && prev_children.nil?
        return
      end

      last_index = 0
      next_index = 0
      next_children.each do |name, next_child|
        prev_child = prev_children && prev_children[name]
        if prev_child == next_child
          move_child(prev_child, next_index, last_index)
          last_index = [prev_child.mount_index, last_index].max
          prev_child.mount_index = next_index
        else
          if prev_child
            last_index = [prev_child.mount_index, last_index].max
            unmount_child(prev_child)
          end

          mount_child_by_name_at_index(next_child, name, next_index, mount_ready, context)
        end
        next_index += 1
      end

      prev_children.each do |name, prev_child|
        unless next_children && next_children.has_key?(name)
          unmount_child(prev_child)
        end
      end
    end

    def update_text_content(next_content)
      @update_depth ||= 0
      @update_depth += 1
      error_thrown = true
      begin
        prev_children = @rendered_children
        if prev_children
          Reconciler.unmount_children(prev_children)
          prev_children.each do |prev_child|
            unmount_child(prev_child)
          end
        end
        set_text_content(next_content)
        error_thrown = false
      ensure
        @update_depth -= 1
        if @update_depth == 0
          unless error_thrown
            process_queue
          else
            clear_queue
          end
        end
      end
    end

    def move_child(child, to_index, last_index)
      if child.mount_index < last_index
        enqueue_move(@root_node_id, child.mount_index, to_index)
      end
    end

    def remove_child(child)
      enqueue_remove(@root_node_id, child.mount_index)
    end

    def unmount_child(child)
      remove_child(child)
      child.mount_index = nil
    end

    def instantiate_children(nested_child_nodes, context)
      Reconciler.flatten_children(nested_child_nodes).map {|name, child|
        child_instance = Hyalite.instantiate_component(child, nil)
        [name, child_instance]
      }.to_h
    end

    def enqueue_remove(parent_id, from_index)
      update_queue << {
        parentID: parent_id,
        parentNode: nil,
        type: :remove_node,
        markupIndex: nil,
        content: nil,
        fromIndex: from_index,
        toIndex: nil
      }
    end

    def enqueue_move(parent_id, from_index, to_index)
      update_queue << {
        parentID: parent_id,
        parentNode: nil,
        type: :move_existing,
        markupIndex: nil,
        content: nil,
        fromIndex: from_index,
        toIndex: to_index
      }
    end

    def process_queue
      if update_queue.any?
        process_children_updates(update_queue, markup_queue)
        clear_queue
      end
    end

    def process_children_updates(updates, markup)
      updates.each do |update|
        update[:parentNode] = Mount.node(update[:parentID])
      end
      process_updates(updates, markup)
    end

    def process_updates(updates, markup_list)
      initial_children = {}
      updated_children = []

      updates.each_with_index do |update, updated_index|
        if update[:type] == :move_existing || update[:type] == :remove_node
          updated_index = update[:fromIndex]
          updated_child = update[:parentNode].elements[updated_index]
          parent_id = update[:parentID]

          initial_children[parent_id] ||= []
          initial_children[parent_id] << updated_child

          updated_children << updated_child
        end
      end

      if markup_list.any? && markup_list[0].is_a?(String)
        #rendered_markup = Danger.dangerouslyRenderMarkup(markupList);
        raise "not implemented"
      else
        rendered_markup = markup_list
      end

      updated_children.each do |child|
        child.remove
      end

      updates.each do |update|
        case update[:type]
        when :insert_markup
          insert_child_at(
            update[:parentNode],
            rendered_markup[update[:markupIndex]],
            update[:toIndex])
        when :move_existing
          insert_child_at(
            update[:parentNode],
            initial_children[update[:parentID]][update[:fromIndex]],
            update[:toIndex])
        when :set_markup
          update[:parentNode].inner_html = update[:content]
        when :text_content
          update[:parentNode].content = update[:content]
        when :remove_node
          # Already removed above.
        end
      end
    end

    def insert_child_at(parent_node, child_node, index)
      if index >= parent_node.children.to_ary.length
        parent_node.add(child_node)
      else
        parent_node[index].add_previous_sibling(child_node)
      end
    end

    private

    def update_queue
      @update_queue ||= []
    end

    def markup_queue
      @markup_queue ||= []
    end

    def mount_child_by_name_at_index(child, name, index, mount_ready, context)
      root_id = @root_node_id + name
      mount_image = Reconciler.mount_component(child, root_id, mount_ready, context)
      child.mount_index = index
      create_child(child, mount_image)
    end

    def create_child(child, mount_image)
      enqueue_markup(@root_node_id, mount_image, child.mount_index)
    end

    def clear_queue
      update_queue.clear
      markup_queue.clear
    end

    def set_text_content(text_content)
      enqueue_text_content(@root_node_id, text_content)
    end

    def enqueue_text_content(parent_id, text_content)
      update_queue << {
        parentID: parent_id,
        parentNode: nil,
        type: :text_content,
        markupIndex: nil,
        textContent: text_content,
        fromIndex: nil,
        toIndex: nil
      }
    end

    def enqueue_markup(parent_id, markup, to_index)
      markup_queue << markup
      update_queue << {
        parentID: parent_id,
        parentNode: nil,
        type: :insert_markup,
        markupIndex: markup_queue.length - 1,
        textContent: nil,
        fromIndex: nil,
        toIndex: to_index
      }
    end

  end
end
