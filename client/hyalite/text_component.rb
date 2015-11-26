require 'hyalite/internal_component'

module Hyalite
  class TextComponent
    include InternalComponent

    def initialize(text)
      @text = text
    end

    def current_element
      @text
    end

    def mount_component(root_id, mount_ready, context)
      @root_node_id = root_id
      @native_node = $document.create_element('span').tap do |node|
        DOMPropertyOperations.set_attribute_for_id(node, root_id)
        Mount.node_id(node)
        node.text = @text
      end
    end

    def unmount_component
      @native_node = nil
      Mount.purge_id(@root_node_id)
    end

    def receive_component(next_text, mount_ready)
      if next_text != @text
        @text = next_text
        DOMOperations.update_text_content(node, @text)
      end
    end

    private

    def node
      @node ||= Mount.node(@root_node_id)
    end
  end
end
