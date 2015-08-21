require_relative 'hyalite.rb'
require 'browser/interval'

class ExampleView
  include Hyalite::Component

  def component_did_mount
    @count = 0
    every(1) do
      set_state({ now: @count += 1 })
    end
  end

  def render
    Hyalite.create_element("div", nil, Hyalite.create_element("h2", nil, "count = #{@state[:now]}"))
  end
end

$document.ready do
  Hyalite.render(Hyalite.create_element(ExampleView, nil), $document['.container'])
end
