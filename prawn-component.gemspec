# frozen_string_literal: true

require File.expand_path('lib/prawn/component/version', __dir__)

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.3.0'

  spec.name        = 'prawn-component'
  spec.version     = ::Prawn::Component::VERSION::STRING
  spec.date        = '2021-07-13'
  spec.summary     = 'The `view_component` gem implemented for Prawn.'
  spec.description = "#{spec.summary} So you can create reusable components."
  spec.authors     = ['halo']
  spec.homepage    = 'https://github.com/halo/prawn-component'

  spec.files         = Dir['{lib}/**/*', 'README*', 'LICENSE.md'] & `git ls-files -z`.split("\0")
  spec.licenses      = ['MIT']
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-initializer'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rb-fsevent'
  spec.add_development_dependency 'rspec'
end
