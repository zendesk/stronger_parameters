# frozen_string_literal: true

require "bundler/setup"
require "bump/tasks"
require "bundler/gem_tasks"

task default: [:test, :fmt]

task :test do
  sh "forking-test-runner test --merge-coverage --quiet"
end

desc "Format code"
task :fmt do
  sh "rubocop --autocorrect"
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
