module Hyalite
  module DOM
    module Event
      EVENT_CLASSES = {
        # MouseEvent
        'click' => MouseEvent,
        'dblclick' => MouseEvent,
        'mousedown' => MouseEvent,
        'mouseup' => MouseEvent,
        'mousemove' => MouseEvent,
        'mouseenter' => MouseEvent,
        'mouseleave' => MouseEvent,
        'mouseover' => MouseEvent,
        'mouseout' => MouseEvent,
        'contextmenu' => MouseEvent,

        # DragEvent
        'drag' => DragEvent,
        'dragstart' => DragEvent,
        'dragend' => DragEvent,
        'dragenter' => DragEvent,
        'dragexit' => DragEvent,
        'dragleave' => DragEvent,
        'dragover' => DragEvent,
        'drop' => DragEvent,

        # KeyboardEvent
        'keydown' => KeyboardEvent,
        'keyup' => KeyboardEvent,
        'keypress' => KeyboardEvent,

        # TouchEvent
        'touchstart' => TouchEvent,
        'touchcancel' => TouchEvent,
        'touchmove' => TouchEvent,
        'touchend' => TouchEvent
      }

      def self.create(event)
        type = `event.type`
        event_class = EVENT_CLASSES[type]
        if event_class
          event_class.new(event)
        end
      end

      def target
        Node.create(`self.native.target`)
      end

      def prevent_default
        `self.native.preventDefault()`
      end
    end
  end
end
