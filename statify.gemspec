# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "statify/version"

Gem::Specification.new do |s|
  s.name        = "statify"
  s.version     = Statify::VERSION
  s.authors     = ["Cyril Picard"]
  s.email       = ["Cyril@picard.ch"]
  s.homepage    = ""
  s.summary     = %q{Statify your models}
  s.description = %q{Enables easy configuration of a status field in your ActiveRecord and Mongoid models.}

  s.rubyforge_project = "statify"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("activesupport", "~>3.0")
  s.add_dependency("activemodel","~>3.0")
end
