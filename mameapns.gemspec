# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mameapns/version'

Gem::Specification.new do |gem|
  gem.name          = "mameapns"
  gem.version       = Mameapns::VERSION
  gem.authors       = ["sutetotanuki"]
  gem.email         = ["sutetotanuki@gmail.com"]
  gem.description   = "mame apns"
  gem.summary       = "mame apns"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency("thor")
  gem.add_development_dependency("rspec")
  gem.add_development_dependency("guard-rspec")
  gem.add_development_dependency("growl")
  gem.add_development_dependency("rb-fsevent", "~> 0.9.1")
end
