#!/usr/bin/env rake

desc "Prepare bundler"
task :prebundle do
  sh 'gem install bundler --version "~> 1.3.1" --no-ri --no-rdoc'
end

desc "Prepare bundle environment"
task :pre do
  sh 'bundle install'
end

task(:default).clear
task :default => :pre
task :all => [ :prebundle, :pre ]
