require_relative 'element'

module Hyalite::DOM
  class Collection
    include Native
    include Enumerable

    def each(&block)
      `self.native.length`.times do |i|
        block.call Element.new(`self.native.item(i)`)
      end

      nil
    end

    def [](index)
      Element.new(`self.native.item(index)`)
    end

    def first
      Element.new(`self.native.item(0)`)
    end

    def last
      Element.new(`self.native.item(self.native.length - 1)`)
    end

    def length
      `self.native.length`
    end
  end
end
