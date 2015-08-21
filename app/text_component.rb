require_relative 'internal_component'

module Hyalite
  include InternalComponent

  class TextComponent
    def initialize(text)
      @text = text
    end

    def mount_component(root_id, transaction, context)
      @text
    end
  end
end
