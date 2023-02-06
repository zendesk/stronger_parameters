# frozen_string_literal: true
require './lib/stronger_parameters/version'

Gem::Specification.new do |spec|
  spec.name          = 'stronger_parameters'
  spec.version       = StrongerParameters::VERSION
  spec.authors       = ['Mick Staugaard']
  spec.email         = ['mick@zendesk.com']
  spec.summary       = 'Type checking and type casting of parameters for Action Pack'
  spec.homepage      = 'https://github.com/zendesk/stronger_parameters'
  spec.license       = 'Apache License Version 2.0'

  spec.files         = Dir.glob('lib/**/*') + %w[README.md]

  spec.add_development_dependency 'bundler', '<= 3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest-rails'
  spec.add_development_dependency 'maxitest'
  spec.add_development_dependency 'bump'
  spec.add_development_dependency 'single_cov'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'forking_test_runner'
  spec.add_runtime_dependency 'actionpack', '>= 5.0', '< 7.1'

  spec.required_ruby_version = '>= 2.7.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
