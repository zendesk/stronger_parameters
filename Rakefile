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

desc "Bundle all gemfiles"
task :bundle_all do
  system("which matching_bundle 2>&1") || abort("gem install matching_bundle")
  Bundler.with_original_env do
    Dir["gemfiles/*.gemfile"].each do |gemfile|
      sh "BUNDLE_GEMFILE=#{gemfile} matching_bundle"
    end
  end
end
