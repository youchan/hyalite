module Hyalite::DOM
  class Text
    include Native
    include Node

    def self.create(text)
      $document.create_text(text)
    end

    def text?
      true
    end
  end
end
