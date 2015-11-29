require 'hyalite/dom_property'
require 'hyalite/utils'

module Hyalite
  module DOMPropertyOperations
    VALID_ATTRIBUTE_NAME_REGEX = /^[a-zA-Z_][a-zA-Z_\.\-\d]*$/

    class << self
      def create_markup_for_property(element, name, value)
        property_info = DOMProperty.property_info(name)
        if property_info
          return if should_ignore_value(property_info, value)

          attribute_name = property_info[:attribute_name]
          if property_info[:has_boolean_value] || property_info[:has_overloaded_boolean_value] && value == true
            element[attribute_name] = ""
            return
          end

          element[attribute_name]=Hyalite.escape_text_content_for_browser(value)
        elsif DOMProperty.is_custom_attribute(name)
          return if value.nil?

          element[name]=Hyalite.escape_text_content_for_browser(value)
        end
      end

      def create_markup_for_custom_attribute(element, name, value)
        return if (!is_attribute_name_safe(name) || value == null)

        element[name]=Hyalite.escape_text_content_for_browser(value)
      end

      def is_attribute_name_safe(attribute_name)
        @illegal_attribute_name_cache ||= {}
        @validated_attribute_name_cache ||= {}

        return true if @validated_attribute_name_cache.has_key? attribute_name
        return false if @illegal_attribute_name_cache.has_key? attribute_name

        if VALID_ATTRIBUTE_NAME_REGEX =~ attribute_name
          @validated_attribute_name_cache[attributeName] = true
          return true
        end

        @illegal_attribute_name_cache[attributeName] = true
        false
      end

      def set_value_for_property(node, name, value)
        property_info = DOMProperty.property_info(name)
        if property_info
          mutation_method = property_info[:mutation_method]
          if mutation_method
            mutation_method.call(node, value);
          elsif should_ignore_value(property_info, value)
            delete_value_for_property(node, name)
          elsif property_info[:must_use_attribute]
            attribute_name = property_info[:attribute_name]
            namespace = property_info[:attribute_namespace]
            if namespace
              node[attribute_name, {namespace: namespace}] = value.to_s
            elsif property_info[:has_boolean_value] ||
                 (property_info[:has_overloaded_boolean_value] && value == true)
              node[attribute_name] = ''
            else
              node[attribute_name] = value.to_s
            end
          else
            prop_name = property_info[:property_name]
            unless property_info[:has_side_effects] && `'' + node[#{prop_name}]` == value.to_s
              `node.native[#{prop_name}] = value`
            end
          end
        elsif DOMProperty.is_custom_attribute(name)
          DOMPropertyOperations.set_value_for_attribute(node, name, value)
        end
      end

      def delete_value_for_property(node, name)
        property_info = DOMProperty.property_info(name)
        if property_info
          mutation_method = property_info[:mutation_method]
          if mutation_method
            mutation_method.call(node, nil)
          elsif property_info[:must_use_attribute]
            node.remove_attribute(property_info[:attribute_name])
          else
            prop_name = property_info[:property_name]
            default_value = DOMProperty.default_value_for_property(node.node_name, prop_name)
            unless property_info[:has_side_effects] || (node[prop_name].to_s == default_value)
              node[prop_name] = default_value
            end
          end
        elsif DOMProperty.is_custom_attribute(name)
          node.remove_attribute(name)
        end
      end

      def set_attribute_for_id(node, id)
        node[DOMProperty::ID_ATTRIBUTE_NAME] = id
      end

      def should_ignore_value(property_info, value)
        value.nil? ||
        (property_info[:has_boolean_value] && !value) ||
        (property_info[:has_numeric_value] && value.nan?) ||
        (property_info[:has_positive_numeric_value] && (value < 1)) ||
        (property_info[:has_overloaded_boolean_value] && value == false)
      end
    end
  end
end
