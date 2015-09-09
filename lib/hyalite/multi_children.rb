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

    # def update_children(next_nested_children, mount_ready, context)
    #   @update_depth += 1
    #   error_thrown = true;
    #   begin
    #     update_children_inner(next_nested_children, mount_ready, context)
    #     error_thrown = false
    #   ensure
    #     @update_depth -= 1
    #     unless @update_depth
    #       if error_thrown
    #         clear_queue
    #       else
    #         process_queue
    #       end
    #     end
    #   end
    # end

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
          last_index = Math.max(prev_child.mount_index, last_index)
          prev_child.mount_index = next_index
        else
          if prev_child
            last_index = Math.max(prev_child.mount_index, last_index)
            unmount_child_by_name(prev_child, name)
          end

          mount_child_by_name_at_index(next_child, name, next_index, mount_ready, context)
        end
        next_index += 1
      end

      prev_children.each do |name, prev_child|
        unless next_children && next_children.has_key?(name)
          unmount_child_by_name(prev_child, name)
        end
      end
    end

    def instantiate_children(nested_child_nodes, context)
      Reconciler.flatten_children(nested_child_nodes).map {|name, child|
        child_instance = Hyalite.instantiate_component(child, nil)
        [name, child_instance]
      }.to_h
    end
  end
end
