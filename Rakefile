# frozen_string_literal: true

require "bundler/setup"
require "standard/rake"
require "bump/tasks"

# Pushing to rubygems is handled by a github workflow
require "bundler/gem_tasks"
ENV["gem_push"] = "false"

task default: [:test, :standard]

task :test do
  sh "forking-test-runner test --merge-coverage --quiet"
end

desc "Bundle all gemfiles [CMD=]"
task :bundle_all do
  cmd = ENV["CMD"]
  Bundler.with_original_env do
    Dir["gemfiles/*.gemfile"].each do |gemfile|
      sh "BUNDLE_GEMFILE=#{gemfile} bundle #{cmd}"
    end
  end
end
