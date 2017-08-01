module Hyalite
  module DOM
    module Event
      class KeyboardEvent
        include Native
        include Event

        alias_native :code
        alias_native :key
        alias_native :shift_key, :shiftKey
        alias_native :alt_key, :altKey
        alias_native :ctrl_key, :ctrlKey
        alias_native :meta_key, :metaKey
        alias_native :locale
        alias_native :location
        alias_native :repeat
        alias_native :composing?, :isComposing
        alias_native :modifierState, :getModifierState
        alias_native :init_key_event, :initKeyEventg
        alias_native :init_keyboard_event, :initKeyboardEventg
      end
    end
  end
end
