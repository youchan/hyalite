require 'spec_helper'

describe 'render' do
  include RenderingHelper

  it 'render plain div element' do
    render do
      Hyalite.create_element('div', {className: 'actual'})
    end
    expect($document['.actual']).to be_a(Browser::DOM::Element)
  end

  it 'render child element' do
    render do
      Hyalite.create_element('div', {className: 'parent'}, Hyalite.create_element('div', {className: 'child'}))
    end

    parent = $document['.parent']
    expect(parent).to be_a(Browser::DOM::Element)
    expect(parent.child).to be_a(Browser::DOM::Element)
    expect(parent.child.class_name).to be('child')
  end

  it 'referrence instance' do
    component = render do
      Hyalite.create_element('div', {className: 'target', ref: 'comp'})
    end

    expect(component.refs[:comp]).to be_a(Browser::DOM::Element)
    expect(component.refs[:comp].class_name).to be('target')
  end

  it 'render update cascaded objcect' do
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

    component = Hyalite.render(Hyalite.create_element(ForceUpdateComponent), DOM('<div/>'))
    component.update_cascaded_object

    expect(component.refs[:target].inner_text).to be('updated')
  end

  it 'render function as Component' do
    FunctionComponent =  Hyalite.fn {|prrops| div({className: 'actual'}, props[:value]) }
    render do
      FunctionComponent.el(value: 'value')
    end

    expect($document['.actual']).to be_a(Browser::DOM::Element)
    expect($document['.actual'].text).to be('value')
  end
end
