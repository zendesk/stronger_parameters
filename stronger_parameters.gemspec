# frozen_string_literal: true

require "./lib/stronger_parameters/version"

Gem::Specification.new do |spec|
  spec.name = "stronger_parameters"
  spec.version = StrongerParameters::VERSION
  spec.authors = ["Mick Staugaard"]
  spec.email = ["mick@zendesk.com"]
  spec.summary = "Type checking and type casting of parameters for Action Pack"
  spec.homepage = "https://github.com/zendesk/stronger_parameters"
  spec.license = "Apache License Version 2.0"

  spec.files = Dir.glob("lib/**/*") + %w[README.md]

  spec.add_runtime_dependency "actionpack", ">= 6.0"

  spec.required_ruby_version = ">= 3.0"
  spec.metadata["rubygems_mfa_required"] = "true"
end
