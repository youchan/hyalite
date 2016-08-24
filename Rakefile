require 'bundler'
Bundler.require

require "bundler/gem_tasks"

task :default => :spec

Opal::Processor.source_map_enabled = true

require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default) do |server, task|
  server.append_path File.expand_path('./client', __FILE__)
  server.source_map = true
  server.debug = true
end

