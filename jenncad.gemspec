# frozen_string_literal: true

require_relative "lib/jenncad/version"

Gem::Specification.new do |spec|
  spec.name    = "jenncad"
  spec.version = JennCad::VERSION
  spec.authors = ["Jennifer Glauche"]
  spec.email   = ["=^.^=@jenncad.kittenme.ws"]

  spec.summary     = %q{TBD}
  spec.description = %q{TBD}
  spec.homepage    = "https://github.com/jglauche/jenncad"
  spec.license     = "LGPL"

  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "https://github.com/jglauche/jenncad/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.bindir = "bin"
  spec.executables = ["jenncad"]
  spec.require_paths = ["lib"]

  spec.add_dependency "geo3d"
  spec.add_dependency "deep_merge"
  spec.add_dependency "hanami-cli"
  spec.add_dependency "activesupport"
  spec.add_dependency "observer"
end
