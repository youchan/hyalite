require_relative 'hyalite.rb'
require 'browser/interval'

class ExampleView
  include Hyalite::Component

  def get_initial_state
    @count = 0
    { now: @count }
  end

  def component_did_mount
    every(1) do
      set_state({ now: @count += 1 })
    end
  end

  def render
    Hyalite.create_element("div", nil,
      Hyalite.create_element("h2", nil, @props[:title]),
      Hyalite.create_element("h3", nil, "count = #{@state[:now]}"))
  end
end

$document.ready do
  Hyalite.render(Hyalite.create_element(ExampleView, {title: "Hyalite counter example"}), $document['.container'])
end
