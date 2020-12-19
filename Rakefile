# frozen_string_literal: true
require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'bump/tasks'

Rake::TestTask.new(:default) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

desc "Run rubocop"
task :rubocop do
  sh "rubocop"
end
