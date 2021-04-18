# frozen_string_literal: true
require 'bundler/setup'
require 'bundler/gem_tasks'
require 'bump/tasks'

task default: [:test, :rubocop]

task :test do
  sh "forking-test-runner test --merge-coverage --quiet"
end

desc "Run rubocop"
task :rubocop do
  sh "rubocop"
end

desc "Bundle all gemfiles"
task :bundle_all do
  Bundler.with_original_env do
    Dir["gemfiles/*.gemfile"].each do |gemfile|
      sh "BUNDLE_GEMFILE=#{gemfile} bundle"
    end
  end
end
