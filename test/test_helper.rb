require 'hyalite'
require 'native'
require "opal/test-unit"

module RenderingHelper
  attr_accessor :mount_at

  def self.included(mod)
    mod.setup do
      $document.body.clear
      mount_at = Hyalite::DOM::Element.create('div').add_class('root')
      $document.body << mount_at
    end
  end

  def render(&block)
    test_component = Class.new do
      include Hyalite::Component
      define_method :render, &block
    end

    mount_at = $document['.root']
    Hyalite.render(Hyalite.create_element(test_component), mount_at)
  end

  def trace_element(element, depth = 0)
    children = element.children.select(&:elem?).map{|c| trace_element(c, depth + 1) } * ''
    text = element.children.select(&:text?).map(&:text) * ' '
    cls = element.attributes['class'] || ''
    (' ' * depth) + "#{element.name.downcase}#{cls ? '.' + cls : ''} #{text}\n#{children}"
  end
end

