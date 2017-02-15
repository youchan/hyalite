require 'spec_helper'

describe 'render method' do
  include RenderingHelper

  it 'render plain div element' do
    render do
      Hyalite.create_element('div', {className: 'actual'})
    end
    expect($document['.actual'].first).to be_a(Hyalite::DOM::Element)
  end

  it 'render child element' do
    render do
      Hyalite.create_element('div', {className: 'parent'}, Hyalite.create_element('div', {className: 'child'}))
    end

    parent = $document['.parent'].first
    expect(parent).to be_a(Hyalite::DOM::Element)
    expect(parent.children.first).to be_a(Hyalite::DOM::Element)
    expect(parent.children.first.class_names.first).to be('child')
  end

  it 'referrence instance' do
    component = render do
      Hyalite.create_element('div', {className: 'target', ref: 'comp'})
    end

    expect(component.refs[:comp]).to be_a(Hyalite::DOM::Element)
    expect(component.refs[:comp].class_names.first).to be('target')
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

    component = Hyalite.render(Hyalite.create_element(ForceUpdateComponent), Hyalite::DOM::Element.create('div'))
    component.update_cascaded_object

    expect(component.refs[:target].text).to be('updated')
  end

  it 'render function as Component' do
    FunctionComponent = Hyalite.fn {|props| div({class: 'actual'}, props[:value]) }
    render do
      FunctionComponent.el(value: 'value')
    end

    expect($document['.actual'].length).to be(1)
    expect($document['.actual'].first).to be_a(Hyalite::DOM::Element)
    expect($document['.actual'].first.text).to be('value')
  end

  it 'update class name' do
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

    expect(component.refs[:target].class_names.first).to be('updated')
  end
end
