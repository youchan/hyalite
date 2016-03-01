require 'spec_helper'

describe 'render' do
  include RenderingHelper

  it 'render plain div element' do
    render do
      Hyalite.create_element('div', {className: 'actual'})
    end
    expect($document['.actual']).to be_a(Browser::DOM::Element)
  end
end
