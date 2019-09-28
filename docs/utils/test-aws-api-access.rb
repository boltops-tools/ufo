# usage 'ruby s3-cert-chain-test.rb'
# see: https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/quick-start-guide.html

require 'aws-sdk-s3' # v2: require 'aws-sdk'
#Aws.use_bundled_cert!

s3 = Aws::S3::Resource.new(region: 'us-east-1')

s3.buckets.limit(50).each do |b|
  puts "#{b.name}"
end
