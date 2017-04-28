module Hyalite::DOM
  class Element
    include Native
    include Node

    alias_native :set_attribute, :setAttribute
    alias_native :get_attribute, :getAttribute
    alias_native :remove_attribute, :removeAttribute
    alias_native :tag_name, :tagName

    def element?
      true
    end

    def input_type
      `self.native.type`
    end

    def [](prop_name)
      `self.native[#{prop_name}]`
    end

    def add_class(name)
      `self.native.classList.add(name)`
      self
    end

    def class_names
      Array.new(`self.native.classList`).to_a
    end

    def attributes
      @attributes ||= Attributes.new(self)
    end

    def text
      `self.native.textContent`
    end

    def text=(text)
      `self.native.textContent = text`
    end

    def value
      `self.native.value`
    end

    def style(hash)
      hash.each do |key, value|
        `self.native.style[key] = value`
      end
    end

    def add_child(child)
      `self.native.appendChild(child.native)`
    end

    def inner_html
      `self.native.innerHTML`
    end

    def inner_html=(html)
      `self.native.innerHTML = html`
    end

    def inner_dom=(dom)
      clear
      self << dom
    end

    def document
      $document
    end

    def to_s
      "<#{`self.native.tagName`} class='#{self.class_names.join(' ')}' id='#{self['id']}'/>"
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
