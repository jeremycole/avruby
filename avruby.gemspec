# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "avr/version"

Gem::Specification.new do |s|
  s.name        = "avruby"
  s.version     = AVR::VERSION
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "An AVR emulator, in Ruby"
  s.license     = "BSD-3-Clause"
  s.description = "An AVR emulator, in Ruby. This was written just for fun, to understand AVR."
  s.authors     = ["Jeremy Cole"]
  s.email       = "jeremy@jcole.us"
  s.homepage    = "https://github.com/jeremycole/avruby"
  s.files = Dir.glob("{bin,lib}/**/*") + ["LICENSE.md", "README.md"]
  s.executables = ["avruby_shell"]
  s.require_path = "lib"

  s.add_development_dependency("rspec")
  s.add_development_dependency("byebug")
  s.add_development_dependency("rubocop")
  s.add_development_dependency("rubocop-rspec")
  s.add_development_dependency("rubocop-shopify")
  s.add_development_dependency("sorbet")

  s.add_dependency("intel_hex", "~> 0.5.3")
  s.add_dependency("sorbet-runtime", "~> 0.5.3")
  s.metadata["rubygems_mfa_required"] = "true"
end
