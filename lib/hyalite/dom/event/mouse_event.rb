module Hyalite
  module DOM
    module Event
      class MouseEvent
        include Native
        include Event
        include MouseEventInterface
      end
    end
  end
end
