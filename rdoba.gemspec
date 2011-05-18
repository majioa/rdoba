# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rdoba/version"

Gem::Specification.new do |s|
  s.name        = "rdoba"
  s.version     = Rdoba::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Малъ Скрылёвъ (Malo Skrylevo)' ]
  s.email       = [ '3aHyga@gmail.com' ]
  s.homepage    = 'https://github.com/3aHyga/rdoba'
  s.summary     = 'Ruby extension library'
  s.description = 'Ruby extension library. It extends Kernel, Object, String, Hash, Array, and some other classes'

  s.rubyforge_project = "rdoba"

  s.required_rubygems_version = '>= 1.6.0'

  s.add_development_dependency("bundler", ">= 1.0.0")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
