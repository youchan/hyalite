module Hyalite
  module DOM
    module Event
      class TouchEvent
        include Native
        include Event

        alias_native :touches
        alias_native :change_touches, :changeTouches
        alias_native :target_touches, :targetTouches
        alias_native :shift_key, :shiftKey
        alias_native :alt_key, :altKey
        alias_native :ctrl_key, :ctrlKey
        alias_native :meta_key, :metaKey
      end
    end
  end
end

