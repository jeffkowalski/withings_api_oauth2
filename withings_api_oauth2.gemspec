# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'withings_api_oauth2/version'

Gem::Specification.new do |spec|
  spec.name          = 'withings_api_oauth2'
  spec.version       = WithingsAPIOAuth2::VERSION
  spec.authors       = ['Sven R.']

  spec.summary       = %q{A Ruby interface to the Withings Web API.}
  spec.homepage      = WithingsAPIOAuth2::REPO_URL
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_runtime_dependency     'oauth2', '~> 1.0'

  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
