require 'opal'
require 'opal-browser'
require 'opal/rspec/rake_task'
require "bundler/gem_tasks"

Opal::Processor.source_map_enabled = true

Opal::RSpec::RakeTask.new(:default) do |server, task|
  server.append_path File.expand_path('../client', __FILE__)
  server.source_map = true
  server.debug = true
end

