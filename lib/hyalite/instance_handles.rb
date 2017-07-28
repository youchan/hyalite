module Hyalite
  module InstanceHandles
    @root_index = 0

    SEPARATOR = '.'

    class << self
      def root_id_string(index)
        SEPARATOR + index.to_s(36)
      end

      def create_root_id
        root_id_string(root_index);
      end

      def root_id_from_node_id(id)
        if id && id.start_with?(SEPARATOR)
          index = id.index(SEPARATOR, 1)
          index ? id[0...index] : id
        end
      end

      def root_index
        index = @root_index
        @root_index += 1
        index
      end

      def traverse_two_phase(target_id, &cb)
        traverse_parent_path('', target_id, true, false, &cb)
        traverse_parent_path(target_id, '', false, true, &cb)
      end

      def traverse_ancestors(target_id, &cb)
        traverse_parent_path('', target_id, true, false, &cb)
      end

      def traverse_parent_path(start, stop, skip_first, skip_last, &cb)
        start = start || ''
        stop = stop || ''
        traverse_up = is_ancestor_id_of(stop, start)

        id = start
        loop do
          unless (skip_first && id == start) || (skip_last && id == stop)
            ret = yield(id, traverse_up)
          end

          if ret == false || id == stop
            break
          end

          id = traverse_up ? parent_id(id) : next_descendant_id(id, stop)
        end
      end

      def parent_id(id)
        id.empty? ? '' : id[0, id.rindex(SEPARATOR)]
      end

      def is_ancestor_id_of(ancestor_id, descendant_id)
        descendant_id.index(ancestor_id) == 0 && is_boundary(descendant_id, ancestor_id.length)
      end

      def is_boundary(id, index)
        id[index] == SEPARATOR || index == id.length
      end

      def next_descendant_id(ancestor_id, destination_id)
        return ancestor_id if ancestor_id == destination_id

        start = ancestor_id.length + SEPARATOR.length
        last = destination_id.index(SEPARATOR, start) || destination_id.length
        destination_id[0,last]
      end
    end
  end
end
