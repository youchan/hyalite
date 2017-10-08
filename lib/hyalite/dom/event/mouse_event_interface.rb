module Hyalite
  module DOM
    module Event
      class AliasPosition
        def initialize(native, name)
          @native = native
          @name = name
        end

        def x
          name = @name + 'X'
          `#@native[name]`
        end

        def y
          name = @name + 'Y'
          `#@native[name]`
        end
      end

      module MouseEventInterface
        def client
          @client ||= AliasPosition.new(@native, :client)
        end

        def movement
          @movement ||= AliasPosition.new(@native, :movement)
        end

        def offset
          @offset ||= AliasPosition.new(@native, :offset)
        end

        def page
          @page ||= AliasPosition.new(@native, :page)
        end

        def screen
          @screen ||= AliasPosition.new(@native, :screen)
        end

        def shift_key
          `#@native.shiftKey`
        end

        def ctrl_key
          `#@native.ctrlKey`
        end

        def alt_key
          `#@native.altKey`
        end

        def meta_key
          `#@native.metaKey`
        end

        def button
          `#@native.button`
        end

        def buttons
          `#@native.buttons`
        end

        def region
          `#@native.region`
        end

        def related_target
          Node.create(`#@native.relatedTarget`)
        end

        def modifire_state
          `#@native.getModifierState()`
        end

        def init_mouse_event
          `#@native.initMouseEvent()`
        end
      end
    end
  end
end
