module Hyalite
  module DOM
    module Event
      class DragEvent
        include Native
        include Event
        include MouseEventInterface

        def drop_effect
          `self.native.dataTransfer.dropEffect`
        end

        def drop_effect=(effect)
          `self.native.dataTransfer.dropEffect = effect`
        end

        def effect_allowed
          `self.native.dataTransfer.effectAllowed`
        end

        def effect_allowed=(effect)
          `self.native.dataTransfer.effectAllowed = effect`
        end

        def data
          DataTransfer.new `self.native.dataTransfer`
        end
      end
    end
  end
end
