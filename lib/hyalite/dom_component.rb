require 'hyalite/multi_children'
require 'hyalite/internal_component'

module Hyalite
  class DOMComponent
    include MultiChildren
    include InternalComponent

    attr_reader :root_node_id

    def initialize(element)
      @element = element
      @tag = @element.type.downcase
    end

    def mount_component(root_id, mount_ready, context)
      return if @tag == "noscript"
      @root_node_id = root_id
      element = create_open_tag_markup_and_put_listeners(mount_ready, @element.props)
      create_content_markup(mount_ready, element, context)
    end

    def unmount_component
      # case @tag
      # when 'iframe', 'img', 'form'
      #   listeners = this._wrapperState.listeners;
      #   if (listeners) {
      #     for (var i = 0; i < listeners.length; i++) {
      #       listeners[i].remove();
      #     }
      #   }
      # case 'input':
      #   ReactDOMInput.unmountWrapper(this);
      # end

      # unmount_children
      # ReactBrowserEventEmitter.deleteAllListeners(this._rootNodeID);
      # ReactComponentBrowserEnvironment.unmountIDFromEnvironment(this._rootNodeID);
      # this._rootNodeID = null;
      # this._wrapperState = null;
      # if (this._nodeWithLegacyProperties) {
      #   var node = this._nodeWithLegacyProperties;
      #   node._reactInternalComponent = null;
      #   this._nodeWithLegacyProperties = null;
      # }
    end

    def receive_component(next_element, mount_ready, context)
      prev_element = @element
      @element = next_element
      update_component(mount_ready, prev_element, next_element, context);
    end

    def update_component(mount_ready, prev_element, next_element, context)
      last_props = prev_element.props
      next_props = @element.props

      # case @tag
      # when 'button':
      #   lastProps = ReactDOMButton.getNativeProps(this, lastProps);
      #   nextProps = ReactDOMButton.getNativeProps(this, nextProps);
      # when 'input':
      #   ReactDOMInput.updateWrapper(this);
      #   lastProps = ReactDOMInput.getNativeProps(this, lastProps);
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
      # end

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

    def update_dom_children(last_props, next_props, mount_ready, context)
      last_contet_is_text = is_text_content(last_props[:children])
      next_content_is_text = is_text_content(next_props[:chilren])

      if !last_contet_is_text && next_content_is_text
        update_children(null, transaction, context)
      elsif last_contet_is_text && !next_content_is_text
        update_text_content('');
      end

      if next_content_is_text && last_props[:children] != next_props[:children]
        update_text_content(next_props[:children]);
      elsif next_props[:children]
        update_children(next_props[:children], mount_ready, context)
      end
    end

    def create_open_tag_markup_and_put_listeners(tmount_ready, props)
      element = $document.create_element(@tag)

      # @props.each do |prop_key, prop_value|
      #   next unless prop_value

      #   if @registration_name_modules.has_key?(prop_key)
      #     enqueuePutListener(this._rootNodeID, propKey, propValue, transaction)
      #   else
      #     if prop_key == STYLE
      #       if prop_value
      #         prop_value = @previous_style_copy = props.style.clone
      #       end
      #       prop_value = CSSPropertyOperations.create_markup_for_styles(prop_value)
      #     end
      #
      #     if is_custom_component(@tag, props)
      #       #markup = DOMPropertyOperations.createMarkupForCustomAttribute(propKey, propValue);
      #     else
      #       #markup = DOMPropertyOperations.createMarkupForProperty(propKey, propValue);
      #     end
      #   end
      # end

      # return element if transaction.render_to_static_markup

      element[Mount::ID_ATTR_NAME] = @root_node_id
      element
    end


    def is_custom_component(tag, props)
      tag.include?('-') || props.has_key?(:is)
    end


    def create_content_markup(mount_ready, element, context)
      children = @element.props[:children]
      if is_text_content(children)
        element.inner_dom = Browser::DOM::Text.create(@element.props[:children])
      else
        mount_images = mount_children(@element.props[:children], mount_ready, context)
        mount_images.each do |image|
          image.append_to(element) if image
        end
      end
      element
    end

    def is_text_content(children)
      case children
      when String, Numeric
        true
      else
        false
      end
    end

    def current_element
      @element
    end
  end
end
