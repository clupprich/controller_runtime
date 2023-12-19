# frozen_string_literal: true

require_relative "lib/controller_runtime/version"

Gem::Specification.new do |spec|
  spec.name = "controller_runtime"
  spec.version = ControllerRuntime::VERSION
  spec.authors = ["Christoph Lupprich"]
  spec.email = ["christoph@luppri.ch"]

  spec.summary = "Easily add runtime information to your Rails app."
  spec.homepage = "https://github.com/clupprich/controller_runtime"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 7.0.0"
  spec.add_runtime_dependency "actionpack", ">= 7.0.0"

  spec.add_development_dependency "rack-test"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
