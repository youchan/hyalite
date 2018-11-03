require 'hyalite'

class ExampleView
  include Hyalite::Component

  state :count, 0

  def component_did_mount
    interval = Proc.new do
      @state.count += 1
      #set_state :count, @state.count
    end

    `setInterval(interval, 5000)`
  end

  def render
    div({class: 'example'},
      h2(nil, @props[:title]),
      h3(nil, "count = #{@state.count}")
    )
  end
end

$document.ready do
  Hyalite.render(Hyalite.create_element(ExampleView, {title: "Hyalite counter example"}), $document['.container'])
end
