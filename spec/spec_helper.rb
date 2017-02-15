require 'hyalite'
require 'native'

module RenderingHelper
  def self.included(mod)
    mod.before do
      $document.body.clear
      @mount_at = Hyalite::DOM::Element.create('div').add_class('root')
      $document.body << @mount_at
    end
  end

  def render(&block)
    class TestComponent
      include Hyalite::Component

      define_method :render, &block
    end

    Hyalite.render(Hyalite.create_element(TestComponent), @mount_at)
  end

  def trace_element(element, depth = 0)
    children = element.children.select(&:elem?).map{|c| trace_element(c, depth + 1) } * ''
    text = element.children.select(&:text?).map(&:text) * ' '
    cls = element.attributes['class'] || ''
    (' ' * depth) + "#{element.name.downcase}#{cls ? '.' + cls : ''} #{text}\n#{children}"
  end
end

