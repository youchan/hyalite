require 'spec_helper'

describe 'context' do
  include RenderingHelper

  it 'render context value as text' do
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
    expect(child).to be_a(Hyalite::DOM::Element)
    expect(child.text).to be('Star ship')
  end

  it 'inherit context to grandchildren' do
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
    expect(child).to be_a(Hyalite::DOM::Element)
    expect(child.text).to be('Star ship')
  end
end

