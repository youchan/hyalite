module Hyalite
  class ElementObject
    attr_reader :type, :key, :ref, :props, :owner

    def initialize(type, key, ref, owner, props)
      @type = type
      @key = key
      @ref = ref
      @owner = owner
      @props = props
    end

    def inspect
      "<#{type} #{props && props.inspect} />"
    end
  end
end
