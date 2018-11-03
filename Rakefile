require "bundler/gem_tasks"
require "opal/test/unit/rake_task"
require "hyalite"

Opal::Test::Unit::RakeTask.new(:default, File.expand_path("../test", __FILE__), runner: :chrome)
