source "https://rubygems.org"

gemspec path: Bundler.root.to_s.sub('/gemfiles', '')

gem 'guard' if RUBY_VERSION > "2.2.5"
gem 'guard-minitest'if RUBY_VERSION > "2.2.5"
