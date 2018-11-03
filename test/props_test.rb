require "test_helper"

module Hyalite
  class PropsTest < Opal::Test::Unit::TestCase
    include RenderingHelper

    test 'text prop' do
      class WithProps
        include Hyalite::Component
        def render
          Hyalite.create_element('div', {className: 'actual'}, @props[:text])
        end
      end

      render do
        Hyalite.create_element(WithProps, {text: 'abc'})
      end

      actual = $document['.actual'].first
      assert_kind_of(Hyalite::DOM::Element, actual)
      assert_equal('abc', actual.text)
    end

    test 'attribute prop' do
      class WithProps
        include Hyalite::Component
        def render
          Hyalite.create_element('div', {className: @props[:attr]})
        end
      end

      render do
        Hyalite.create_element(WithProps, {'attr': 'abc'})
      end

      actual = $document['.abc'].first
      assert_kind_of(Hyalite::DOM::Element, actual)
    end
  end
end
