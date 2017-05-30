# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ufo/version'

Gem::Specification.new do |spec|
  spec.name          = "ufo"
  spec.version       = Ufo::VERSION
  spec.authors       = ["Tung Nguyen"]
  spec.email         = ["tongueroo@gmail.com"]
  spec.description   = %q{Build Docker Containers and Ship Them to AWS ECS}
  spec.summary       = %q{Build Docker Containers and Ship Them to AWS ECS}
  spec.homepage      = "https://github.com/tongueroo/ufo"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "hashie"
  spec.add_dependency "colorize"
  spec.add_dependency "deep_merge"
  spec.add_dependency "aws-sdk"
  spec.add_dependency "plissken"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
