module Hyalite::DOM
  module EventTarget
    def on(name, &block)
      callback = Proc.new{|event| block.call(Event.create(event))}
      `#@native.addEventListener(name, callback)`
    end
  end
end
