require 'opal'
require 'hyalite/logger'
require 'hyalite/transaction'
require 'hyalite/adler32'
require 'hyalite/mount'
require 'hyalite/element'
require 'hyalite/dom_component'
require 'hyalite/text_component'
require 'hyalite/dom'

module Hyalite
  class << self
    RESERVED_PROPS = [:key, :ref, :children]

    def create_element(type, config = nil, *children)
      key = nil
      ref = nil

      props = {}

      if config
        key = config[:key]
        ref = config[:ref]

        config.each do |name, value|
          unless RESERVED_PROPS.include?(name)
            props[name] = config[name];
          end
        end
      end

      props[:children] = case children.length
                         when 0
                           nil
                         when 1
                           children.first
                         else
                           children
                         end

      ElementObject.new(type, key, ref, Hyalite.current_owner, props)
    end

    def fn(&block)
      Class.new {
        include Component
        include Component::ShortHand

        def self.render_proc=(proc)
          @render_proc = proc
        end

        def self.render_proc
          @render_proc
        end

        def render
          self.instance_exec(@props, &self.class.render_proc)
        end
      }.tap{|cl| cl.render_proc = block }
    end

    def instantiate_component(node)
      node = EmptyComponent.empty_element if node.nil?

      case node
      when ElementObject
        case node.type
        when String
          DOMComponent.new node
        when Class
          if node.type.include?(InternalComponent)
            node.type.new
          elsif node.type.include?(Component)
            CompositeComponent.new node
          else
            raise "Encountered invalid type of Hyalite node. type: #{node.type}"
          end
        end
      when String, Numeric
        TextComponent.new node
      when EmptyComponent
        CompositeComponent.new node
      else
        raise "Encountered invalid Hyalite node: #{node}"
      end
    end

    def render(next_element, container, &block)
      Mount.render_subtree_into_container(nil, next_element, container, &block);
    end

    def instance_map
      @instance_map ||= {}
    end

    def current_owner(current_owner = nil)
      if current_owner && block_given?
        begin
          @current_owner = current_owner
          yield(@current_owner)
        ensure
          @current_owner = nil
        end
      else
        @current_owner
      end
    end

    def find_dom_node(component_or_element)
      return component_or_element if component_or_element.respond_to?(:node_type) && component_or_element.element?

      if instance_map.has_key?(component_or_element)
        return Mount.node(instance_map[component_or_element].root_node_id)
      end
    end
  end
end
