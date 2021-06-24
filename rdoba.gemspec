# -*- encoding: utf-8 -*-
# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require "rdoba/_version_"

Gem::Specification.new do |s|
   s.name         = "rdoba"
   s.version      = Rdoba::VERSION
   s.platform     = Gem::Platform::RUBY
   s.authors      = [ 'Малъ Скрылёвъ (Malo Skrylevo)' ]
   s.email        = [ '3aHyga@gmail.com' ]
   s.homepage     = 'https://github.com/3aHyga/rdoba'
   s.summary      = 'Ruby extension library (Ruby DOBAvka)'
   s.description  = 'Ruby extension library. It extends Kernel, Object, '       \
                    'String, Hash, Array, and some other classes. Also allows ' \
                    'to log application state with debug lines to an io'
   s.license      = 'MIT'

   s.rubyforge_project = "rdoba"
   s.files             = `git ls-files`.split("\n")
   s.test_files        = `git ls-files -- {test,spec,features}/*`.split("\n")
   s.executables       = `git ls-files -- bin/*`.split( "\n" ).map{ |f| File.basename(f) }
   s.require_paths     = [ "lib" ]
   s.extra_rdoc_files  = [ 'README.md', 'LICENSE', 'CHANGES.md' ] |
                        `find html/`.split( "\n" )

   s.add_development_dependency 'bundler', '~> 2.0'
   s.add_development_dependency 'coveralls'
   s.add_development_dependency 'cucumber', '~> 1.3'
   s.add_development_dependency 'ffi-stat', '~> 0.4'
   s.add_development_dependency 'rake', '~> 12.0', '>= 12.3.3'
   s.add_development_dependency 'rdiscount', '~> 2.1'
   s.add_development_dependency 'rdoc', '~> 6.2'
   s.add_development_dependency 'rspec-expectations', '~> 3.3'
   s.add_development_dependency 'simplecov', '~> 0'
   s.add_development_dependency 'tddium', '~> 1.25'

   s.required_rubygems_version = '>= 1.6.0'
   s.required_ruby_version = '>= 1.9.0' ; end
