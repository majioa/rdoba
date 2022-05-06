# frozen_string_literal: true

require "bundler/gem_tasks"
require 'cucumber/rake/task'
require 'rdoc/task'

Cucumber::Rake::Task.new

# RDoc::Task.new do |rdoc|
#   rdoc.main = "README.md"
#   rdoc.rdoc_files.include( "README.md", "lib/**/*.rb" ) ; end
#
# desc "Prepare bundler"
# task :bundleup do
#  sh 'gem install bundler --version "~> 1.5" --no-ri --no-rdoc'
# end
#
# desc "Requires"
# task :req do
#   $: << File.expand_path( '../lib', __FILE__ )
#   require 'bundler/gem_helper'
#
#   Bundler::GemHelper.install_tasks
# end
#
# desc "Prepare bundle environment"
# task :up do
#  sh 'bundle install'
# end
#
# desc "Distilled clean"
# task :distclean do
#   sh 'git clean -fd'
#   # sh 'cat .gitignore | while read mask; do rm -rf $(find -iname "$mask"); done'
# end
#
# desc "Generate gem"
# namespace :gem do
#  task :build => [ :req ] do
#    sh 'gem build rdoba.gemspec'
#  end
#
#  task :install do
#    require File.expand_path( '../lib/rdoba/_version_', __FILE__ )
#    sh "gem install rdoba-#{Rdoba::VERSION}.gem"
#  end
#
#  task :publish => [ :req ] do
#    require File.expand_path( '../lib/rdoba/_version_', __FILE__ )
#    sh "gem push rdoba-#{Rdoba::VERSION}.gem"
#    sh "git tag v#{Rdoba::VERSION}"
#    sh "git push"
#    sh "git push --tag"
#  end
#
#  task :make => [ :build, :install, :publish ]
#  task :default => :make
# end
#
task(:default).clear
task :default => :cucumber
# task :codeclimate => :cucumber
# task :all => [ :bundleup, :up, :cucumber, :'gem:make', :distclean ]
# task :build => [ :bundleup, :up, :cucumber, :rdoc,
#   :'gem:build', :'gem:install', :distclean ]
