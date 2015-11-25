require 'hyalite/internal_component'

module Hyalite
  include InternalComponent

  class TextComponent
    attr_accessor :mount_index

    def initialize(text)
      @text = text
      @mount_index = 0
    end

    def current_element
      @text
    end

    def mount_component(root_id, transaction, context)
      @text
    end
  end
end
