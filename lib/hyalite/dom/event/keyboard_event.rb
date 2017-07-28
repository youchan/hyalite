module Hyalite
  module DOM
    module Event
      class KeyboardEvent
        include Native
        include Event

        alias_native :code
        alias_native :key_code, :keyCode
      end
    end
  end
end
