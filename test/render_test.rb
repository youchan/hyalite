require "test_helper"

module Hyalite
  class RenderTest < Opal::Test::Unit::TestCase

    include RenderingHelper

    test 'rendering plain div element' do
      render do
        Hyalite.create_element('div', {className: 'actual'})
      end

      assert_kind_of(Hyalite::DOM::Element, $document['.actual'].first)
    end

    test 'rendering child element' do
      render do
        Hyalite.create_element('div', {className: 'parent'}, Hyalite.create_element('div', {className: 'child'}))
      end

      parent = $document['.parent'].first
      assert_kind_of(Hyalite::DOM::Element, parent)
      assert_kind_of(Hyalite::DOM::Element, parent.children.first)
      assert_equal('child', parent.children.first.class_names.first)
    end

    test 'referrence of the instance' do
      components = render do
        Hyalite.create_element('div', {className: 'target', ref: 'comp'})
      end

      component = components.first

      assert_kind_of(Hyalite::DOM::Element, component.refs[:comp])
      assert_equal('target', component.refs[:comp].class_names.first)
    end

    test 'update cascaded objcect' do
      class ForceUpdateComponent
        include Hyalite::Component

        def initialize
          @value =  { cascaded: 'initial' }
        end

        def initial_state
          { value: @value }
        end

        def update_cascaded_object
          @value[:cascaded] = 'updated'
          force_update
        end

        def render
          Hyalite.create_element('div', {ref: 'target'}, @value[:cascaded])
        end
      end

      component = Hyalite.render(Hyalite.create_element(ForceUpdateComponent), Hyalite::DOM::Element.create('div'))
      component.update_cascaded_object

      assert_equal('updated', component.refs[:target].text)
    end

    test 'render function as Component' do
      FunctionComponent = Hyalite.fn {|props| div({class: 'actual'}, props[:value]) }
      render do
        FunctionComponent.el(value: 'value')
      end

      assert_equal(1, $document['.actual'].length)
      assert_kind_of(Hyalite::DOM::Element, $document['.actual'].first)
      assert_equal('value', $document['.actual'].first.text)
    end

    test 'update class name' do
      class UpdateClassNameComponent
        include Hyalite::Component

        state :class_name, 'default'

        def update_class_name
          @state.class_name = 'updated'
        end

        def render
          div({ref: 'target', class: @state.class_name})
        end
      end

      component = Hyalite.render(Hyalite.create_element(UpdateClassNameComponent), Hyalite::DOM::Element.create('div'))

      component.update_class_name

      assert_equal('updated', component.refs[:target].class_names.first)
    end
  end
end
