module Hyalite
  module DOMProperty
    ID_ATTRIBUTE_NAME = 'data-hyalite-id'

    MUST_USE_ATTRIBUTE           = 1
    MUST_USE_PROPERTY            = 2
    HAS_BOOLEAN_VALUE            = 4
    HAS_SIDE_EFFECTS             = 8
    HAS_NUMERIC_VALUE            = 16
    HAS_POSITIVE_NUMERIC_VALUE   = 32
    HAS_OVERLOADED_BOOLEAN_VALUE = 64

    PROPERTIES = {
      ###############################
      ### Standard Properties
      ###############################
      accept: nil,
      acceptCharset: nil,
      accessKey: nil,
      action: nil,
      allowFullScreen: MUST_USE_ATTRIBUTE | HAS_BOOLEAN_VALUE,
      allowTransparency: MUST_USE_ATTRIBUTE,
      alt: nil,
      async: HAS_BOOLEAN_VALUE,
      autoComplete: nil,
      # autoFocus is polyfilled/normalized by AutoFocusUtils
      # autoFocus: HAS_BOOLEAN_VALUE,
      autoPlay: HAS_BOOLEAN_VALUE,
      capture: MUST_USE_ATTRIBUTE | HAS_BOOLEAN_VALUE,
      cellPadding: nil,
      cellSpacing: nil,
      charSet: MUST_USE_ATTRIBUTE,
      challenge: MUST_USE_ATTRIBUTE,
      checked: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      classID: MUST_USE_ATTRIBUTE,
      className: MUST_USE_PROPERTY,
      cols: MUST_USE_ATTRIBUTE | HAS_POSITIVE_NUMERIC_VALUE,
      colSpan: nil,
      content: nil,
      contentEditable: nil,
      contextMenu: MUST_USE_ATTRIBUTE,
      controls: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      coords: nil,
      crossOrigin: nil,
      data: nil, # For `<object />` acts as `src`.
      dateTime: MUST_USE_ATTRIBUTE,
      defer: HAS_BOOLEAN_VALUE,
      dir: nil,
      disabled: MUST_USE_ATTRIBUTE | HAS_BOOLEAN_VALUE,
      download: HAS_OVERLOADED_BOOLEAN_VALUE,
      draggable: nil,
      encType: nil,
      form: MUST_USE_ATTRIBUTE,
      formAction: MUST_USE_ATTRIBUTE,
      formEncType: MUST_USE_ATTRIBUTE,
      formMethod: MUST_USE_ATTRIBUTE,
      formNoValidate: HAS_BOOLEAN_VALUE,
      formTarget: MUST_USE_ATTRIBUTE,
      frameBorder: MUST_USE_ATTRIBUTE,
      headers: nil,
      height: MUST_USE_ATTRIBUTE,
      hidden: MUST_USE_ATTRIBUTE | HAS_BOOLEAN_VALUE,
      high: nil,
      href: nil,
      hrefLang: nil,
      htmlFor: nil,
      httpEquiv: nil,
      icon: nil,
      id: MUST_USE_PROPERTY,
      inputMode: MUST_USE_ATTRIBUTE,
      is: MUST_USE_ATTRIBUTE,
      keyParams: MUST_USE_ATTRIBUTE,
      keyType: MUST_USE_ATTRIBUTE,
      label: nil,
      lang: nil,
      list: MUST_USE_ATTRIBUTE,
      loop: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      low: nil,
      manifest: MUST_USE_ATTRIBUTE,
      marginHeight: nil,
      marginWidth: nil,
      max: nil,
      maxLength: MUST_USE_ATTRIBUTE,
      media: MUST_USE_ATTRIBUTE,
      mediaGroup: nil,
      method: nil,
      min: nil,
      minLength: MUST_USE_ATTRIBUTE,
      multiple: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      muted: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      name: nil,
      noValidate: HAS_BOOLEAN_VALUE,
      open: HAS_BOOLEAN_VALUE,
      optimum: nil,
      pattern: nil,
      placeholder: nil,
      poster: nil,
      preload: nil,
      radioGroup: nil,
      readOnly: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      rel: nil,
      required: HAS_BOOLEAN_VALUE,
      role: MUST_USE_ATTRIBUTE,
      rows: MUST_USE_ATTRIBUTE | HAS_POSITIVE_NUMERIC_VALUE,
      rowSpan: nil,
      sandbox: nil,
      scope: nil,
      scoped: HAS_BOOLEAN_VALUE,
      scrolling: nil,
      seamless: MUST_USE_ATTRIBUTE | HAS_BOOLEAN_VALUE,
      selected: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      shape: nil,
      size: MUST_USE_ATTRIBUTE | HAS_POSITIVE_NUMERIC_VALUE,
      sizes: MUST_USE_ATTRIBUTE,
      span: HAS_POSITIVE_NUMERIC_VALUE,
      spellCheck: nil,
      src: nil,
      srcDoc: MUST_USE_PROPERTY,
      srcSet: MUST_USE_ATTRIBUTE,
      start: HAS_NUMERIC_VALUE,
      step: nil,
      style: nil,
      tabIndex: nil,
      target: nil,
      title: nil,
      type: nil,
      useMap: nil,
      value: MUST_USE_PROPERTY | HAS_SIDE_EFFECTS,
      width: MUST_USE_ATTRIBUTE,
      wmode: MUST_USE_ATTRIBUTE,

      ###############################
      ### Non-standard Properties
      ###############################
      # autoCapitalize and autoCorrect are supported in Mobile Safari for
      # keyboard hints.
      autoCapitalize: nil,
      autoCorrect: nil,
      # itemProp, itemScope, itemType are for
      # Microdata support. See http:#schema.org/docs/gs.html
      itemProp: MUST_USE_ATTRIBUTE,
      itemScope: MUST_USE_ATTRIBUTE | HAS_BOOLEAN_VALUE,
      itemType: MUST_USE_ATTRIBUTE,
      # itemID and itemRef are for Microdata support as well but
      # only specified in the the WHATWG spec document. See
      # https:#html.spec.whatwg.org/multipage/microdata.html#microdata-dom-api
      itemID: MUST_USE_ATTRIBUTE,
      itemRef: MUST_USE_ATTRIBUTE,
      # property is supported for OpenGraph in meta tags.
      property: nil,
      # IE-only attribute that specifies security restrictions on an iframe
      # as an alternative to the sandbox attribute on IE<10
      security: MUST_USE_ATTRIBUTE,
      # IE-only attribute that controls focus behavior
      unselectable: MUST_USE_ATTRIBUTE,
    }

    DOM_ATTRIBUTE_NAMES = {
      acceptCharset: 'accept-charset',
      className: 'class',
      htmlFor: 'for',
      httpEquiv: 'http-equiv'
    }

    class << self
      def property_info(name)
        return nil unless PROPERTIES.has_key? name.to_sym

        @property_info ||= {}
        unless @property_info.has_key? name
          property = PROPERTIES[name.to_sym]

          attribute_name = DOM_ATTRIBUTE_NAMES.has_key?(name) ? DOM_ATTRIBUTE_NAMES[name] : name.downcase

          @property_info[name] = {
            attribute_name: attribute_name,
            attribute_namespace: nil,
            property_name: name,
            mutation_method: nil,
            must_use_attribute: property && property & MUST_USE_ATTRIBUTE > 0,
            must_use_property: property && property & MUST_USE_PROPERTY > 0,
            has_side_effects: property && property & HAS_SIDE_EFFECTS > 0,
            has_boolean_value: property && property & HAS_BOOLEAN_VALUE > 0,
            has_numeric_value: property && property & HAS_NUMERIC_VALUE > 0,
            has_positive_numeric_value: property && property & HAS_POSITIVE_NUMERIC_VALUE > 0,
            has_overloaded_boolean_value: property && property & HAS_OVERLOADED_BOOLEAN_VALUE > 0
          }
        end

        @property_info[name]
      end

      def include?(name)
        PROPERTIES.has_key? name
      end

      def default_value_for_property(node_name, prop)
        node_defaults = default_value_cache[node_name]
        unless node_defaults
          default_value_cache[node_name] = node_defaults = {}
        end
        unless node_defaults.include? prop
          test_element = $document.create_element(node_name)
          node_defaults[prop] = test_element[prop]
        end
        node_defaults[prop]
      end

      def default_value_cache
        @default_value_cache ||= {}
      end

      def is_custom_attribute(attribute_name)
        !!(/^(data|aria)-[a-z_][a-z\d_.\-]*$/ =~ attribute_name)
      end
    end
  end
end
