require 'spec_helper'

describe 'render' do
  it 'render plain div element' do
    mount_at = DOM("<div class='root'></div>")
    mount_at.append_to($document.body)

    class TestComponent
      include Hyalite::Component
      def render
        Hyalite.create_element('div', {className: 'actual'})
      end
    end
    Hyalite.render(Hyalite.create_element(TestComponent), mount_at)

    expect($document['.actual']).to be_a(Browser::DOM::Element)
  end
end
