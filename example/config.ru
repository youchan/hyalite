require 'bundler'
Bundler.require

run Opal::Sprockets::Server.new { |s|
  s.append_path 'app'
  s.append_path '../lib'

  s.debug = true
  s.main = 'application'
  s.index_path = 'index.html.haml'
}

