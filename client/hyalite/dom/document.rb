module Hyalite::DOM
  class Document
    include Native
    include Node

    def create_element(tag)
      Element.new `self.native.createElement(tag)`
    end

    def create_text(text)
      Text.new `self.native.createTextNode(text)`
    end

    def body
      Body.new `self.native.body`
    end

    def ready(&block)
      `self.native.addEventListener('DOMContentLoaded', block)`
    end

    def self.singleton
      @singleton ||= self.new(`window.document`)
    end

    def document?
      true
    end

    def [](q)
      elements = []
      %x(
        var nodeList = self.native.querySelectorAll(#{q});
        for (var i = 0; i < nodeList.length; i++) {
          elements.$push(nodeList.item(i));
        }
      )
      elements.map!{|el| Element.new(el) }
    end
  end
end
