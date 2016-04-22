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
end
