module Hyalite
  module DOM
  end
end

require 'native'
require_relative 'dom/event/mouse_event_interface'
require_relative 'dom/event/data_transfer'
require_relative 'dom/event/keyboard_event'
require_relative 'dom/event/mouse_event'
require_relative 'dom/event/drag_event'
require_relative 'dom/event/touch_event'
require_relative 'dom/event'
require_relative 'dom/node'
require_relative 'dom/collection'
require_relative 'dom/text'
require_relative 'dom/element'
require_relative 'dom/body'
require_relative 'dom/document'

$document = Hyalite::DOM::Document.singleton
