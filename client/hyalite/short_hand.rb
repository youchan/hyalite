module Hyalite
  module Component
    module ShortHand
      TAGS = %w(h1 h2 h3 h4 h5 h6 header footer section div p span code strong a img input button label ul li)

      def self.included(klass)
        TAGS.each do |tag|
          define_method(tag) do |props, *children|
            Hyalite.create_element(tag, props, *children)
          end
        end

        klass.extend ClassMethods
      end

      module ClassMethods
        def el(props, *children)
          Hyalite.create_element(self, props, *children)
        end
      end
    end
  end
end
