require "test_helper"

module Hyalite
  class ContextTest < Opal::Test::Unit::TestCase
    include ::RenderingHelper

    test 'context value should render as text' do
      class ParentComonent
        include Hyalite::Component

        def child_context
          { text: 'Star ship' }
        end

        def render
          Hyalite.create_element(ChildComponent, {className: 'parent'})
        end
      end

      class ChildComponent
        include Hyalite::Component

        def render
          Hyalite.create_element('div', {class: 'child'}, @context[:text])
        end
      end

      render do
        Hyalite.create_element(ParentComonent)
      end

      child = $document['.child'].first
      assert_kind_of(Hyalite::DOM::Element, child)
      assert_equal('Star ship', child.text)
    end

    test 'grandchildren' do
      class ParentComonent
        include Hyalite::Component

        def child_context
          { text: 'Star ship' }
        end

        def render
          Hyalite.create_element(ChildComponent, {className: 'parent'})
        end
      end

      class ChildComponent
        include Hyalite::Component

        def render
          Hyalite.create_element(GrandchildComponent, {class: 'child'}, @context[:text])
        end
      end

      class GrandchildComponent
        include Hyalite::Component

        def render
          Hyalite.create_element('div', {class: 'grandchild'}, @context[:text])
        end
      end

      render do
        Hyalite.create_element(ParentComonent)
      end

      child = $document['.grandchild'].first
      assert_kind_of(Hyalite::DOM::Element, child)
      assert_equal('Star ship', child.text)
    end
  end
end

