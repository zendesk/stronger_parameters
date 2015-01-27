require 'bundler/setup'
require 'bundler/gem_tasks'
require 'wwtd/tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => "wwtd:local"
