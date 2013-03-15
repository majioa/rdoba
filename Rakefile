#!/usr/bin/env rake

desc "Prepare bundler"
task :prebundle do
  sh 'gem install bundler --version "~> 1.3.1" --no-ri --no-rdoc'
end

desc "Prepare bundle environment"
task :pre do
  sh 'bundle install'
end

desc "Generate gem"
namespace :gem do
  task :build do
    sh 'gem build rdoba.gemspec'
  end

  task :install do
    require File.expand_path( '../lib/rdoba/_version_', __FILE__ )
    sh "gem install rdoba-#{Rdoba::VERSION}.gem"
  end

  task :publish do
    require File.expand_path( '../lib/rdoba/_version_', __FILE__ )
    sh "git tag v#{Rdoba::VERSION}"
    sh "git push"
    sh "git push --tag"
    sh "gem push rdoba-#{Rdoba::VERSION}.gem"
  end

  task :make => [ :build, :install, :publish ]
  task :default => :make
end

task(:default).clear
task :default => :pre
task :all => [ :prebundle, :pre ]
