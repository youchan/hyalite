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
      `self.native[name]`
    end

    def node_name
      `self.native.tagName`
    end

    def <<(child)
      `self.native.appendChild(child.native)`
    end

    def clear
      %x(
        var len = self.native.childNodes.length;
        for (var i = 0; i < len; i++) {
          self.native.childNodes[0].remove();
        }
      )
    end

    def parent
      if parent = `self.native.parentNode`
        Node.create(parent)
      end
    end

    def children
      Collection.new `self.native.childNodes`
    end

    def remove
      `self.native.remove()`
    end

    def next_sibling
      sib = `self.native.nextSibling`
      Node.create(sib) if sib
    end

    def ==(other)
      `self.native === other.native`
    end
  end
end
