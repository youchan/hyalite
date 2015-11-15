require 'set'
require 'math'
require 'hyalite/event_dispatcher'
require 'hyalite/synthetic_event'

module Hyalite
  module BrowserEvent
    EVENT_TYPES = {
      keyDown: {
        phasedRegistrationNames: {
          bubbled: "onKeyDown",
          captured: "onKeyDownCapture"
        },
      },
    }

    TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG = {
      topKeyDown: EVENT_TYPES[:keyDown]
    }

    REGISTRATION_NAME_DEPENDENCIES = {
      "onKeyDown" => [:topKeyDown]
    }

    TOP_EVENT_MAPPING = { topKeyDown: "keydown" }

    TOP_LISTENERS_ID_KEY = '_hyliteListenersID' + Math.rand.to_s.chars.drop(2).join

    class << self
      def registration_names
        @registrasion_names ||= Set.new.tap do |names|
          TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG.each_value do |value|
            value[:phasedRegistrationNames].each_value do |name|
              names << name
            end
          end
        end
      end

      def include?(name)
        registration_names.include? name
      end

      def listen_to(registration_name, content_document_handle)
        mount_at = content_document_handle
        is_listening = listening_for_document(mount_at)
        dependencies = REGISTRATION_NAME_DEPENDENCIES[registration_name]

        dependencies.each do |dependency|
          unless is_listening.has_key? dependency && is_listening[dependency]
            case dependency
            when :top_wheel
              nil
            #   if isEventSupported('wheel')
            #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
            #       topLevelTypes.topWheel,
            #       'wheel',
            #       mountAt
            #     );
            #   elsif isEventSupported('mousewheel')
            #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
            #       topLevelTypes.topWheel,
            #       'mousewheel',
            #       mountAt
            #     );
            #   else
            #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
            #       topLevelTypes.topWheel,
            #       'DOMMouseScroll',
            #       mountAt
            #     );
            #   end
            # when :top_scroll
            #   if isEventSupported('scroll', true)
            #     ReactBrowserEventEmitter.ReactEventListener.trapCapturedEvent(
            #       topLevelTypes.topScroll,
            #       'scroll',
            #       mountAt
            #     );
            #   else
            #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
            #       topLevelTypes.topScroll,
            #       'scroll',
            #       ReactBrowserEventEmitter.ReactEventListener.WINDOW_HANDLE
            #     );
            #   end
            # when :top_focus, :top_blur
            #   if isEventSupported('focus', true)
            #     ReactBrowserEventEmitter.ReactEventListener.trapCapturedEvent(
            #       topLevelTypes.topFocus,
            #       'focus',
            #       mountAt
            #     );
            #     ReactBrowserEventEmitter.ReactEventListener.trapCapturedEvent(
            #       topLevelTypes.topBlur,
            #       'blur',
            #       mountAt
            #     );
            #   elsif isEventSupported('focusin')
            #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
            #       topLevelTypes.topFocus,
            #       'focusin',
            #       mountAt
            #     );
            #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
            #       topLevelTypes.topBlur,
            #       'focusout',
            #       mountAt
            #     );
            #   end
            #
            #   is_listening[:top_blur] = true
            #   is_listening[:top_focus] = true
            else
              if TOP_EVENT_MAPPING.has_key? dependency
                event_dispatcher.trap_bubbled_event(dependency, TOP_EVENT_MAPPING[dependency], mount_at)
              end
            end

            is_listening[dependency] = true;
          end
        end
      end

      def extract_event(top_level_type, top_level_target_id, event)
        dispatch_config = TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG[top_level_type]
        return [] unless dispatch_config

        SyntheticEvent.new(top_level_type, event).tap do |synthetic_event|
          InstanceHandles.traverse_two_phase(top_level_target_id) do |target_id, upwards|
            listener = listener_at_phase(target_id, dispatch_config, upwards ? :bubbled : :captured)
            synthetic_event.add_listener(listener, target_id) if listener
          end
        end
      end

      def put_listener(id, event_name, listener)
        event_dispatcher.put_listener(id, event_name, listener)
      end

      def listener_at_phase(id, dispatch_config, propagation_phase)
        registration_name = dispatch_config[:phasedRegistrationNames][propagation_phase]
        event_dispatcher.get_listener(id, registration_name)
      end

      def listening_for_document(mount_at)
        @already_listening_to ||= []
        unless `Object.prototype.hasOwnProperty.call(mount_at.native, #{TOP_LISTENERS_ID_KEY})`
          `mount_at.native[#{TOP_LISTENERS_ID_KEY}] = #{@already_listening_to.length}`
          @already_listening_to << {}
        end
        @already_listening_to[`mount_at.native[#{TOP_LISTENERS_ID_KEY}]`]
      end

      def enabled?
        event_dispatcher.enabled?
      end

      def enabled=(enabled)
        event_dispatcher.enabled = enabled
      end

      def event_dispatcher
        @event_dispatcher ||= EventDispatcher.new do |top_level_type, top_level_target_id, event|
          extract_event(top_level_type, top_level_target_id, event)
        end
      end
    end
  end
end
