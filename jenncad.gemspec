# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "jenncad"

Gem::Specification.new do |gem|
  gem.name        = "jenncad"
  gem.version     = JennCad::VERSION
  gem.authors     = ["Jennifer Glauche"]
  gem.email       = ["=^.^=@jenncad.kittenme.ws"]
  gem.homepage    = ""
  gem.summary     = %q{TBD}
  gem.description = %q{TBD}

  gem.license     = 'LGPL-3'
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6.0"
  gem.add_runtime_dependency "geo3d"
  gem.add_runtime_dependency "deep_merge"
  gem.add_runtime_dependency "hanami-cli", "0.3.1"
  gem.add_runtime_dependency "activesupport"
  gem.add_runtime_dependency "observr"
end
