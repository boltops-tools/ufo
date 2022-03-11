lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ufo/version"

Gem::Specification.new do |spec|
  spec.name          = "ufo"
  spec.version       = Ufo::VERSION
  spec.authors       = ["Tung Nguyen"]
  spec.email         = ["tongueroo@gmail.com"]
  spec.summary       = "AWS ECS Deploy Tool"
  spec.homepage      = "http://ufoships.com"
  spec.license       = "MIT"

  vendor_files       = Dir.glob("vendor/**/*")
  spec.files         = `git ls-files`.split($/) + vendor_files
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-logs"
  spec.add_dependency "aws-mfa-secure", ">= 0.4.3"
  spec.add_dependency "aws-sdk-acm"
  spec.add_dependency "aws-sdk-applicationautoscaling"
  spec.add_dependency "aws-sdk-cloudformation"
  spec.add_dependency "aws-sdk-cloudwatchlogs"
  spec.add_dependency "aws-sdk-ec2"
  spec.add_dependency "aws-sdk-ecr"
  spec.add_dependency "aws-sdk-ecs"
  spec.add_dependency "aws-sdk-elasticloadbalancingv2"
  spec.add_dependency "aws-sdk-ssm"
  spec.add_dependency "aws-sdk-wafv2"
  spec.add_dependency "aws_data"
  spec.add_dependency "cfn-status"
  spec.add_dependency "cli-format"
  spec.add_dependency "deep_merge"
  spec.add_dependency "dsl_evaluator", ">= 0.2.5" # for DslEvaluator.print_code
  spec.add_dependency "memoist"
  spec.add_dependency "plissken"
  spec.add_dependency "rainbow"
  spec.add_dependency "render_me_pretty"
  spec.add_dependency "rexml"
  spec.add_dependency "thor"
  spec.add_dependency "tty-screen"
  spec.add_dependency "zeitwerk"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "cli_markdown"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
