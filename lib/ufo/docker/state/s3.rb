class Ufo::Docker::State
  class S3 < Base
    extend Memoist
    include Ufo::AwsServices

    def read
      current_data
    end

    def update
      data = current_data
      data["base_image"] = @base_image

      # write data to s3
      body = YAML.dump(data)
      s3.put_object(
        body: body,
        bucket: s3_bucket,
        key: s3_key,
      )
      logger.info "Updated base image in s3://#{s3_bucket}/#{s3_key}"
      logger.info "    #{@base_image}".color(:green)
    end

    # TODO: edge cases: no bucket, no permission
    def current_data
      resp = s3.get_object(bucket: s3_bucket, key: s3_key)
      YAML.load(resp.body)
    rescue Aws::S3::Errors::NoSuchKey
      logger.debug "WARN: s3 key does not exist: #{s3_key}"
      {}
    rescue Aws::S3::Errors::NoSuchBucket
      logger.error "ERROR: S3 bucket does not exist to store state: #{s3_bucket}".color(:red)
      logger.error <<~EOL
          Please double check the config.

          See: http://ufoships.com/docs/config/state/

      EOL
      exit 1
    end

    def s3_key
      "ufo/state/#{app}/#{Ufo.env}/data.yml"
    end

    # ufo docker base is called before Ufo.config is loaded. This ensures it is loaded
    def app
      Ufo.app
    end

    def s3_bucket
      state = Ufo.config.state
      if state.bucket
        state.bucket
      elsif state.managed
        ensure_s3_bucket_exist
        Ufo::S3::Bucket.name
      else
        logger.error "ERROR: No s3 bucket to store state".color(:red)
        logger.error <<~EOL
          UFO needs a bucket to store the built docker base image.

          Configure an existing bucket or enable UFO to create a bucket.

          See: http://ufoships.com/docs/config/state/
        EOL
        exit 1
      end
    end

    def ensure_s3_bucket_exist
      bucket = Ufo::S3::Bucket.new
      return if bucket.exist?
      bucket.deploy
    end
    memoize :ensure_s3_bucket_exist
  end
end
