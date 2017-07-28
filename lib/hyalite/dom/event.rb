module Hyalite
  module DOM
    module Event
      EVENT_CLASSES = {
        'click' => MouseEvent,
        'keydown' => KeyboardEvent
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
    end
  end
end
