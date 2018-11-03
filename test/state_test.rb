require "test_helper"

module Hyalite
  class StateTest < Opal::Test::Unit::TestCase
    include RenderingHelper

    test 'DSL' do
      class StateDefinition
        include Hyalite::Component

        state :test, ''

        def update_state
          @state.test = 'test'
        end

        def render
          Hyalite.create_element('div', { ref: 'actual' }, @state.test)
        end
      end

      component = Hyalite.render(Hyalite.create_element(StateDefinition), Hyalite::DOM::Element.create('div'))
      component.update_state

      actual = component.refs['actual']
      assert_equal('test', actual.text)
    end
  end
end
