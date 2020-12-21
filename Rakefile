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
  Bundler.with_original_env do
    system("which -s matching_bundle") || abort("gem install matching_bundle")
    Dir["gemfiles/*.gemfile"].each do |gemfile|
      sh "BUNDLE_GEMFILE=#{gemfile} matching_bundle"
    end
  end
end
