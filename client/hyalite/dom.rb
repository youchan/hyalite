module Hyalite
  module DOM
  end
end

require 'native'
require_relative 'dom/node'
require_relative 'dom/collection'
require_relative 'dom/text'
require_relative 'dom/element'
require_relative 'dom/body'
require_relative 'dom/document'

$document = Hyalite::DOM::Document.singleton
