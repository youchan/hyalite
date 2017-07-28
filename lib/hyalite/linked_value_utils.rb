module Hyalite
  module LinkedValueUtils
    class << self
      def value(props)
        if props.has_key? :valueLink
          props[:valueLink][:value]
        else
          props[:value]
        end
      end

      def checked(props)
        if props.has_key? :checkedLink
          props[:checkedLink][:value]
        else
          props[:checked]
        end
      end

      def execute_on_change(props, event)
        if props.has_key? :onChange
          props[:onChange].call(event)
        end
      end
    end
  end
end
