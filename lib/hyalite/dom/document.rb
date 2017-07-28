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
      Collection.new `self.native.querySelectorAll(#{q})`
    end
  end
end
