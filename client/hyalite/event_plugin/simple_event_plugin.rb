module Hyalite
  class SimpleEventPlugin
    EVENT_TYPES = {
      keyDown: {
        phasedRegistrationNames: {
          bubbled: "onKeyDown",
          captured: "onKeyDownCapture"
        }
      },

      invalid: {
        phasedRegistrationNames: {
          bubbled: "onInvalid",
          captured: "onInvalidCapture"
        }
      },
    }

    TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG = {
      topKeyDown: EVENT_TYPES[:keyDown],
      topInvalid: EVENT_TYPES[:invalid]
    }

    def initialize
      TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG.each do |type, dispatch_config|
        dispatch_config[:dependencies] = [type]
      end
    end

    def event_types
      EVENT_TYPES
    end

    def extract_event(top_level_type, top_level_target, top_level_target_id, event)
      dispatch_config = TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG[top_level_type]
      return [] unless dispatch_config

      SyntheticEvent.new(event).tap do |synthetic_event|
        InstanceHandles.traverse_two_phase(top_level_target_id) do |target_id, upwards|
          listener = BrowserEvent.listener_at_phase(target_id, dispatch_config, upwards ? :bubbled : :captured)
          synthetic_event.add_listener(listener, target_id) if listener
        end
      end
    end
  end
end
