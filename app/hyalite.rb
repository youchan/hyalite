require 'opal'
require 'browser'
require_relative 'transaction'
require_relative 'adler32'
require_relative 'mount'
require_relative 'element'
require_relative 'dom_component'
require_relative 'text_component'

module Hyalite
  class << self
    def create_element(type, config = nil, *children)
      key = nil
      ref = nil

      if config
        key = config.key
        ref = config.ref
      end

      props = {}

      props[:children] = children.length == 1 ? children.first : children

      ElementObject.new(type, key, ref, Hyalite.current_owner, props)
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
      else
        raise "Encountered invalid Hyalite node: #{node}"
      end
    end

    def render(nextElement, container)
      proc = block_given? ? Proc.new {|c| yield(c) } : nil
      Mount.render_subtree_into_container(nil, nextElement, container, &proc);
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
  end
end
