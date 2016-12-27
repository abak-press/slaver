# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slaver/version'

Gem::Specification.new do |spec|
  spec.name          = "slaver"
  spec.version       = Slaver::VERSION
  spec.authors       = ["Denis Korobitcin"]
  spec.email         = ["deniskorobitcin@gmail.com"]

  spec.summary       = %q{Instant change of connection in rails application.}
  spec.homepage      = "https://github.com/abak-press/slaver"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activerecord', '>= 3.1.0', '< 5.0'
  spec.add_runtime_dependency 'activesupport', '>= 3.1.0', '< 5.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'combustion', '>= 0.5.0', '< 0.5.5'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'shoulda-matchers', '< 3.0.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'sqlite3'
end
