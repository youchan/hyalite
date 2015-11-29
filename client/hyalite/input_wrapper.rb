require 'json'
require 'hyalite/linked_value_utils'
require 'hyalite/dom_operations'

module Hyalite
  class InputWrapper
    include LinkedValueUtils

    def initialize(dom_component)
      @dom_component = dom_component
    end

    def mount_wrapper
      props = @dom_component.current_element.props
      @wrapper_state = {
        initialChecked: props[:default_checked] || false,
        initialValue: props[:default_value],
        listeners: nil,
        onChange: -> (event) { handle_change(event) }
      }
    end

    def unmount_wrapper
    end

    def native_props(inst)
      props = @dom_component.current_element.props

      props.merge({
        defaultChecked: nil,
        defaultValue: nil,
        value: props[:value] || @wrapper_state[:initialValue],
        checked: props[:checked] || @wrapper_state[:initialChecked],
        onChange: @wrapper_state[:onChange],
      })
    end

    def force_update_if_mounted(instance)
      if instance.root_node_id
        update_wrapper
      end
    end

    def update_wrapper
      props = @dom_component.current_element.props
      checked = props[:checked]
      if checked
        node = Mount.node(@dom_component.root_node_id)
        node[:checked] = checked
      end

      value = LinkedValueUtils.value(props)
      if value
        DOMOperations.update_property_by_id(
          @dom_component.root_node_id,
          'value',
          value.to_s
        )
      end
    end

    def handle_change(event)
      props = @dom_component.current_element.props
      return_value = execute_on_change(props, event)

      Hyalite.updates.asap { force_update_if_mounted(@dom_component) }

      if props[:type] == 'radio' && props[:name]
        root_node = Mount.node(root_node_id)
        query_root = root_node

        while query_root.parent
          query_root = query_root.parent
        end

        group = query_root =~ "input[name='#{name.to_json}'][type='radio']"

        group.each do |other_node|
          next if other_node == root_node || other_node.form != root_node.form

          other_id = Mount.node_id(other_node)
          other_instance = Mount.instances_by_root_id(other_id)
          Hyalite.updates.asap { force_update_if_mounted(other_instance) }
        end
      end

      return_value
    end
  end
end
