module Hyalite::DOM
  class Window
    include Native
    include EventTarget

    native_reader :document

    def location
      Native(`#@native.location`)
    end

    def width
      `#@native.innerWidth`
    end

    def height
      `#@native.innerHeight`
    end

    def self.singleton
      @singleton ||= self.new(`window`)
    end
  end
end
