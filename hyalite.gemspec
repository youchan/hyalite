# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hyalite/version'

Gem::Specification.new do |spec|
  spec.name          = "hyalite"
  spec.version       = Hyalite::VERSION
  spec.authors       = ["youchan"]
  spec.email         = ["youchan01@gmail.com"]

  spec.summary       = %q{Virtual DOM implimentation in Ruby}
  spec.description   = %q{Virtual DOM implimentation in Ruby using Opal}
  spec.homepage      = 'https://github.com/youchan/hyalite'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'opal', "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 13.0"
end
