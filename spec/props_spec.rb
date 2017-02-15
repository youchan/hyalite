require 'spec_helper'

describe 'props' do
  include RenderingHelper

  it 'render props as text' do
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
    expect(actual).to be_a(Hyalite::DOM::Element)
    expect(actual.text).to be('abc')
  end

  it 'render props as an attribute' do
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
    expect(actual).to be_a(Hyalite::DOM::Element)
  end
end
