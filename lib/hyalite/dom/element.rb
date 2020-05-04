module Hyalite::DOM
  class Element
    include Native
    include Node

    alias_native :set_attribute, :setAttribute
    alias_native :get_attribute, :getAttribute
    alias_native :remove_attribute, :removeAttribute
    alias_native :tag_name, :tagName

    native_accessor :value

    def element?
      true
    end

    def input_type
      `#@native.type`
    end

    def [](prop_name)
      `#@native[#{prop_name}]`
    end

    def add_class(name)
      `#@native.classList.add(name)`
      self
    end

    def class_names
      Array.new(`#@native.classList`).to_a
    end

    def attributes
      @attributes ||= Attributes.new(self)
    end

    def text
      `#@native.textContent`
    end

    def text=(text)
      `#@native.textContent = text`
    end

    def width
      `#@native.clientWidth`
    end

    def height
      `#@native.clientHeight`
    end

    def top
      `#@native.clientTop`
    end

    def left
      `#@native.clientLeft`
    end

    def style(hash)
      hash.each do |key, value|
        `#@native.style[key] = value`
      end
    end

    def add_child(child)
      `#@native.appendChild(child.native)`
    end

    def inner_html
      `#@native.innerHTML`
    end

    def inner_html=(html)
      `#@native.innerHTML = html`
    end

    def inner_dom=(dom)
      clear
      self << dom
    end

    def document
      $document
    end

    def to_s
      "<#{`#@native.tagName`} class='#{self.class_names.join(' ')}' id='#{self['id']}' />"
    end

    def self.create(tag)
      $document.create_element(tag)
    end

    class Attributes
      def initialize(element)
        @element = element
      end

      def [](name)
        @element.get_attribute(name)
      end

      def []=(name, value)
        @element.set_attribute(name, value)
      end

      def remove(name)
        @element.remove_attribute(name)
      end
    end
  end
end
