class Browser::DOM::Element
  def input_type
    `self.native.type`
  end
end

module Hyalite
  class ChangeEventPlugin
    EVENT_TYPES = {
      change: {
        phasedRegistrationNames: {
          bubbled: "onChange",
          captured: "onChangeCapture"
        },
        dependencies: [
          :topBlur,
          :topChange,
          :topClick,
          :topFocus,
          :topInput,
          :topKeyDown,
          :topKeyUp,
          :topSelectionChange
        ]
      }
    }

    SUPPORTED_INPUT_TYPES = [
      'color',
      'date',
      'datetime',
      'datetime-local',
      'email',
      'month',
      'number',
      'password',
      'range',
      'search',
      'tel',
      'text',
      'time',
      'url',
      'week'
    ]

    def event_types
      EVENT_TYPES
    end

    def is_text_input_element(elem)
      node_name = elem.node_name.downcase
      (node_name == 'input' && SUPPORTED_INPUT_TYPES.include?(elem.input_type)) || node_name == 'textarea'
    end

    def should_use_change_event(elem)
      node_name = elem.node_name.downcase
      node_name == 'select' || (node_name == 'input' && elem.input_type == 'file')
    end

    def should_use_click_event(elem)
      elem.node_name.downcase == 'input' && %w(checkbox radio).include?(elem.input_type)
    end

    def extract_event(top_level_type, top_level_target, top_level_target_id, event)
      if should_use_change_event(top_level_target)
        target_id = top_level_target_id if top_level_type == :topChange
      elsif is_text_input_element(top_level_target)
        target_id = top_level_target_id if top_level_type == :topInput
      elsif should_use_click_event(top_level_target)
        target_id = top_level_target_id if top_level_type == :topClick
      end

      if target_id
        SyntheticEvent.new(event).tap do |synthetic_event|
          InstanceHandles.traverse_two_phase(target_id) do |target_id, upwards|
            listener = BrowserEvent.listener_at_phase(target_id, EVENT_TYPES[:change], upwards ? :bubbled : :captured)
            synthetic_event.add_listener(listener, target_id) if listener
          end
        end
      end
    end
  end
end
