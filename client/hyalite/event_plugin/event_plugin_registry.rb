module Hyalite
  class EventPluginRegistry
    def initialize(*plugins)
      @registration_name_modules = {}
      @registration_name_dependencies = {}
      @plugins = []
      plugins.each {|plugin| add_plugin(plugin) }
    end

    def add_plugin(plugin)
      plugin.event_types.each do |key, dispatch_config|
        dispatch_config[:phasedRegistrationNames].each do |phase, registration_name|
          @registration_name_modules[registration_name] = plugin
          @registration_name_dependencies[registration_name] = dispatch_config[:dependencies]
        end
      end
      @plugins << plugin
    end

    def include?(registration_name)
      @registration_name_modules.has_key? registration_name
    end

    def dependencies(registration_name)
      @registration_name_dependencies[registration_name]
    end

    def [](registration_name)
      @registration_name_modules[registration_name]
    end

    def extract_events(top_level_type, top_level_target, top_level_target_id, event)
      @plugins.each.with_object([]) do |plugin, events|
        synthetic_event = plugin.extract_event(top_level_type, top_level_target, top_level_target_id, event)
        events << synthetic_event if synthetic_event
      end
    end

    def registration_names
      @registrasion_names ||= Set.new.tap do |names|
        TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG.each_value do |value|
          value[:phasedRegistrationNames].each_value do |name|
            names << name
          end
        end
      end
    end
  end
end
