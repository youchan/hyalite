require 'hyalite/multi_children'
require 'hyalite/dom_property_operations'
require 'hyalite/internal_component'
require 'hyalite/browser_event'
require 'hyalite/input_wrapper'

module Hyalite
  class DOMComponent
    include MultiChildren
    include InternalComponent

    attr_reader :root_node_id

    def initialize(element)
      @element = element
      @tag = @element.type.downcase
      @input_wrapper = InputWrapper.new(self)
    end

    def current_element
      @element
    end

    def mount_component(root_id, mount_ready, context)
      return if @tag == "noscript"
      @root_node_id = root_id

      props = current_element.props

      case @tag
      # when 'iframe', 'img', 'form', 'video', 'audio'
      #   this._wrapperState = {
      #     listeners: null,
      #   }
      #   transaction.getReactMountReady().enqueue(trapBubbledEventsLocal, this);
      # when 'button'
      #   props = ReactDOMButton.getNativeProps(this, props, nativeParent);
      when 'input'
        @input_wrapper.mount_wrapper
        props = @input_wrapper.native_props
      # when 'option'
      #   ReactDOMOption.mountWrapper(this, props, nativeParent);
      #   props = ReactDOMOption.getNativeProps(this, props);
      # when 'select'
      #   ReactDOMSelect.mountWrapper(this, props, nativeParent);
      #   props = ReactDOMSelect.getNativeProps(this, props);
      #   transaction.getReactMountReady().enqueue(trapBubbledEventsLocal, this);
      # when 'textarea'
      #   ReactDOMTextarea.mountWrapper(this, props, nativeParent);
      #   props = ReactDOMTextarea.getNativeProps(this, props);
      #   transaction.getReactMountReady().enqueue(trapBubbledEventsLocal, this);
      end

      element = create_open_tag_markup_and_put_listeners(mount_ready, @element.props)
      create_content_markup(mount_ready, element, context)
    end

    def unmount_component
      case @tag
      # when 'iframe', 'img', 'form'
      #   listeners = this._wrapperState.listeners;
      #   if (listeners) {
      #     for (var i = 0; i < listeners.length; i++) {
      #       listeners[i].remove();
      #     }
      #   }
      when 'input'
        InputWrapper.unmount_wrapper
      end

      unmount_children
      BrowserEvent.delete_all_listeners(@root_node_id)
      Mount.purge_id(@root_node_id)
      @root_node_id = nil
      # @wrapper_state = null;
      if @node_with_legacy_properties
        node = @node_with_legacy_properties
        node.internal_component = nil
        @node_with_legacy_properties = nil
      end
    end

    def receive_component(next_element, mount_ready, context)
      prev_element = @element
      @element = next_element
      update_component(mount_ready, prev_element, next_element, context);
    end

    def update_component(mount_ready, prev_element, next_element, context)
      last_props = prev_element.props
      next_props = @element.props

      case @tag
      # when 'button':
      #   lastProps = ReactDOMButton.getNativeProps(this, lastProps);
      #   nextProps = ReactDOMButton.getNativeProps(this, nextProps);
      when 'input':
        @input_wrapper.update_wrapper
        last_props = @input_wrapper.native_props(last_props)
      #   nextProps = ReactDOMInput.getNativeProps(this, nextProps);
      # when 'option':
      #   lastProps = ReactDOMOption.getNativeProps(this, lastProps);
      #   nextProps = ReactDOMOption.getNativeProps(this, nextProps);
      # when 'select':
      #   lastProps = ReactDOMSelect.getNativeProps(this, lastProps);
      #   nextProps = ReactDOMSelect.getNativeProps(this, nextProps);
      # when 'textarea':
      #   ReactDOMTextarea.updateWrapper(this);
      #   lastProps = ReactDOMTextarea.getNativeProps(this, lastProps);
      #   nextProps = ReactDOMTextarea.getNativeProps(this, nextProps);
      end

      # assertValidProps(this, nextProps);
      #update_dom_properties(lastProps, nextProps, transaction);
      update_dom_children(last_props, next_props, mount_ready, context)

      # if (!canDefineProperty && this._nodeWithLegacyProperties) {
      #   this._nodeWithLegacyProperties.props = nextProps;
      # }

      if @tag == 'select'
        mount_ready.enqueue { post_update_select_wrapper }
      end
    end

    def public_instance
      native_node
    end

    private

    def native_node
      @native_node ||= Mount.node(@root_node_id)
    end

    def update_dom_children(last_props, next_props, mount_ready, context)
      last_content = last_props[:children] if is_text_content(last_props[:children])
      next_content = next_props[:children] if is_text_content(next_props[:children])

      last_html = last_props[:dangerouslySetInnerHTML].try {|_| _['__html'] }
      next_html = next_props[:dangerouslySetInnerHTML].try {|_| _['__html'] }

      last_children = last_props[:children] unless last_content
      next_children = next_props[:children] unless next_content

      last_has_content_or_html = !last_content.nil? || !last_html.nil?
      next_has_content_or_html = !next_content.nil? || !next_html.nil?
      if last_children && next_children.nil?
        update_children(nil, mount_ready, context)
      elsif last_has_content_or_html && !next_has_content_or_html
        update_text_content('')
      end

      if next_content
        unless last_content == next_content
          update_text_content(next_content.to_s)
        end
      elsif next_html
        unless last_html == next_html
          update_markup(next_html.to_s)
        end
      elsif next_children
        update_children(next_children, mount_ready, context)
      end
    end

    def create_open_tag_markup_and_put_listeners(mount_ready, props)
      element = $document.create_element(@tag)

      props.each do |prop_key, prop_value|
        next unless prop_value

        if BrowserEvent.include?(prop_key)
          enqueue_put_listener(@root_node_id, prop_key, prop_value, mount_ready)
        else
          if prop_key == :style
            if prop_value
              prop_value = @previous_style_copy = props.style.clone
            end
            prop_value = DOMPropertyOperations.create_markup_for_styles(prop_value)
          end

          if is_custom_component(@tag, props)
            DOMPropertyOperations.create_markup_for_custom_attribute(element, prop_key, prop_value)
          else
            DOMPropertyOperations.create_markup_for_property(element, prop_key, prop_value)
          end
        end
      end

      #return element if mount_ready.render_to_static_markup

      element[Mount::ID_ATTR_NAME] = @root_node_id
      element
    end

    def create_content_markup(mount_ready, element, context)
      children = @element.props[:children]
      if is_text_content(children)
        element.inner_dom = Browser::DOM::Text.create(@element.props[:children])
      else
        mount_images = mount_children(@element.props[:children], mount_ready, context)
        mount_images.each do |image|
          if image.is_a?(String)
            element.text = image
          else
            image.append_to(element) if image
          end
        end
      end
      element
    end

    def enqueue_put_listener(id, event_name, listener, mount_ready)
      container = Mount.container_for_id(id)
      if container
        doc = container.node_type == Browser::DOM::Node::ELEMENT_NODE ? container.document : container
        BrowserEvent.listen_to(event_name, doc)
      end
      mount_ready.enqueue do
        BrowserEvent.put_listener(id, event_name, listener)
      end
    end

    def is_custom_component(tag, props)
      tag.include?('-') || props.has_key?(:is)
    end

    def is_text_content(children)
      case children
      when String, Numeric
        true
      else
        false
      end
    end
  end
end
