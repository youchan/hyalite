module Hyalite
  module DOM
    module Event
      class DataTransfer
        include Native

        alias_native :clear, :createData
        alias_native :drag_image=, :setDragImage

        native_reader :files
        native_reader :items
        native_reader :types

        def []=(name, value)
          `self.native.setData(name, value)`
        end

        def [](name)
          `self.native.getData(name)`
        end
      end
    end
  end
end
