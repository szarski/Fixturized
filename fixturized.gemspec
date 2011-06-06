# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fixturized/version"

Gem::Specification.new do |s|
  s.name        = "fixturized"
  s.version     = Fixturized::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jacek Szarski", "Marcin Bunsch"]
  s.email       = ["jacek@applicake.com"]
  s.homepage    = ""
  s.summary     = %q{A work in porgress on speeding up your tests by caching initialized data into fixtures}
  s.description = %q{A work in porgress on speeding up your tests by caching initialized data into fixtures}

  s.rubyforge_project = "fixturized"

  s.add_dependency "sourcify"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
