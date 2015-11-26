require 'set'
require 'math'
require 'hyalite/event_dispatcher'
require 'hyalite/synthetic_event'
require 'hyalite/event_plugin/event_plugin_registry'
require 'hyalite/event_plugin/simple_event_plugin'
require 'hyalite/event_plugin/change_event_plugin'

module Hyalite
  module BrowserEvent
    TOP_EVENT_MAPPING = {
      topKeyDown: "keydown",
      topChange: "change",
      topInput: "input",
      topInvalid: "invalid"
    }

    TOP_LISTENERS_ID_KEY = '_hyliteListenersID' + Math.rand.to_s.chars.drop(2).join

    class << self
      def enabled?
        event_dispatcher.enabled?
      end

      def enabled=(enabled)
        event_dispatcher.enabled = enabled
      end

      def event_dispatcher
        @event_dispatcher ||= EventDispatcher.new do |top_level_type, top_level_target, top_level_target_id, event|
          event_plugin_registry.extract_events(top_level_type, top_level_target, top_level_target_id, event)
        end
      end

      def event_plugin_registry
        @event_plugin_registry ||= EventPluginRegistry.new(
          SimpleEventPlugin.new,
          ChangeEventPlugin.new
        )
      end

      def include?(name)
        event_plugin_registry.include? name
      end

      def listen_to(registration_name, content_document_handle)
        mount_at = content_document_handle
        is_listening = listening_for_document(mount_at)
        dependencies = event_plugin_registry.dependencies(registration_name)

        dependencies.each do |dependency|
          unless is_listening[dependency]
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
                trap_bubbled_event(dependency, TOP_EVENT_MAPPING[dependency], mount_at)
              end
            end

            is_listening[dependency] = true
          end
        end
      end

      def put_listener(id, event_name, listener)
        event_dispatcher.put_listener(id, event_name, listener)
      end

      def delete_all_listeners(id)
        event_dispatcher.delete_all_listeners(id) do |registration_name, id|
          plugin = event_plugin_registry[registration_name]
          if plugin.respond_to? :will_delete_listener
            plugin.will_delete_listener(id, registration_name)
          end
        end
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

      def trap_bubbled_event(top_level_type, handler_base_name, handle)
        event_dispatcher.trap_bubbled_event(top_level_type, handler_base_name, handle)
      end
    end
  end
end
