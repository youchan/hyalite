require 'opal'
require 'opal/rspec/rake_task'
require "bundler/gem_tasks"

Opal::Config.source_map_enabled = true

Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.files = [ENV['FILE']] if ENV['FILE']
  server.append_path File.expand_path('../client', __FILE__)
  server.source_map = true
  server.debug = true
end

