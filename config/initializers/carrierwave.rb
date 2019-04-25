# frozen_string_literal: true

if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_provider = "fog/aws"
    config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: ENV["S3_KEY"],
      aws_secret_access_key: ENV["S3_SECRET"],
      region: ENV["S3_REGION"]
    }
    config.fog_directory  = ENV["S3_BUCKET_NAME"]
    config.fog_public     = false
    config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
end
