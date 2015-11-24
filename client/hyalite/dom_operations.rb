require 'hyalite/dom_property_operations'

module Hyalite
  module DOMOperations

    def self.update_property_by_id(id, name, value)
      node = Mount.node(id)

      if value
        DOMPropertyOperations.set_value_for_property(node, name, value)
      else
        DOMPropertyOperations.delete_value_for_property(node, name)
      end
    end
  end
end
