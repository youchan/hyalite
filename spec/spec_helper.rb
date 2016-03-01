require 'hyalite'

module RenderingHelper
  def self.included(mod)
    mod.before do
      @mount_at = DOM("<div class='root'></div>")
      @mount_at.append_to($document.body)
    end
  end

  def render(&block)
    class TestComponent
      include Hyalite::Component

      define_method :render, &block
    end

    Hyalite.render(Hyalite.create_element(TestComponent), @mount_at)
  end
end

