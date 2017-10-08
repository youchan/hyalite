module Hyalite
  module Dom
    module Event
      class FocusEvent
        include Native
        include Event

        def related_target
          Node.create(`#@native.relatedTarget`)
        end
      end
    end
  end
end
