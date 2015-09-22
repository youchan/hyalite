require 'hyalite/dom_property'
require 'hyalite/utils'

module Hyalite
  module DOMPropertyOperations
    VALID_ATTRIBUTE_NAME_REGEX = /^[a-zA-Z_][a-zA-Z_\.\-\d]*$/

    def self.create_markup_for_property(element, name, value)
      property_info = DOMProperty.property_info(name)
      if property_info
        return if should_ignore_value(property_info, value)

        attribute_name = property_info[:attribute_name]
        if property_info[:has_boolean_value] || property_info[:has_overloaded_boolean_value] && value == true
          element[attribute_name] = ""
          return
        end

        element[attribute_name]=Hyalite.quote_attribute_value_for_browser(value)
      elsif DOMProperty.is_custom_attribute(name)
        return if value.nil?

        element[name]=Hyalite.quote_attribute_value_for_browser(value)
      end
    end

    def self.create_markup_for_custom_attribute(element, name, value)
      return if (!is_attribute_name_safe(name) || value == null)

      element[name]=Hyalite.quote_attribute_value_for_browser(value)
    end

    def self.is_attribute_name_safe(attribute_name)
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

    def self.should_ignore_value(property_info, value)
      value.nil? ||
      (property_info[:has_boolean_value] && !value) ||
      (property_info[:has_numeric_value] && value.nan?) ||
      (property_info[:has_positive_numeric_value] && (value < 1)) ||
      (property_info[:has_overloaded_boolean_value] && value == false)
    end
  end
end
