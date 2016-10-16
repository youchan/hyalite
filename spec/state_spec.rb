require 'spec_helper'

describe 'state' do
  include RenderingHelper

  it 'state definition' do
    class StateDefinition
      include Hyalite::Component

      state :test, ''

      def update_state
        # @state.test = 'test'
        set_state(test:'test')
      end

      def render
        Hyalite.create_element('div', { ref: 'actual' }, @state.test)
      end
    end

    component = Hyalite.render(Hyalite.create_element(StateDefinition), DOM('<div/>'))
    component.update_state

    actual = component.refs['actual']
    expect(actual.text).to be('test')
  end
end
