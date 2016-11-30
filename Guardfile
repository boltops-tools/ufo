guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})      { "spec/ufo_spec.rb" }
  watch(%r{^lib/ufo/(.+)\.rb$})  { "spec/ufo_spec.rb" }
  watch('spec/spec_helper.rb')   { "spec/ufo_spec.rb" }
  watch(%r{^lib/ufo/(.+)\.rb$})   { |m| "spec/lib/#{m[1]}_spec.rb" }
end

guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end
