# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stronger_parameters/version'

Gem::Specification.new do |spec|
  spec.name          = 'stronger_parameters'
  spec.version       = StrongerParameters::VERSION
  spec.authors       = ['Mick Staugaard']
  spec.email         = ['mick@zendesk.com']
  spec.summary       = 'Type checking and type casting of parameters for Action Pack'
  spec.homepage      = 'https://github.com/zendesk/stronger_parameters'
  spec.license       = 'Apache License Version 2.0'

  spec.files         = Dir.glob('lib/**/*') + Dir.glob('test/**/*') + %w(README.md)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_path  = 'lib'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'

  spec.add_dependency 'strong_parameters', '~> 0.2'
end
