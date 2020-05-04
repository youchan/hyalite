module Hyalite::DOM
  module Node
    include EventTarget

    attr_reader :native

    def self.create(node)
      @classes ||= [nil, Element, nil, Text, nil, nil, nil, nil, nil, Document, nil, nil]

      if klass = @classes[`node.nodeType`]
        klass.new(node)
      else
        raise ArgumentError, 'cannot instantiate a non derived Node object'
      end
    end

    def document?
      false
    end

    def element?
      false
    end

    def text?
      false
    end

    def attr(name)
      `#@native[name] || #{nil}`
    end

    def data(name)
      `#@native.dataset[#{name}] || #{nil}`
    end

    def node_name
      `#@native.tagName`
    end

    def <<(child)
      `#@native.appendChild(child.native)`
    end

    def clear
      %x(
        var len = #@native.childNodes.length;
        for (var i = 0; i < len; i++) {
          #@native.childNodes[0].remove();
        }
      )
    end

    def parent
      if parent = `#@native.parentNode`
        Node.create(parent)
      end
    end

    def children
      Collection.new `#@native.childNodes`
    end

    def remove
      `#@native.remove()`
    end

    def next_sibling
      sib = `#@native.nextSibling`
      Node.create(sib) if sib
    end

    def ==(other)
      `#@native === other.native`
    end
  end
end
