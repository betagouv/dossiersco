require 'carrierwave'

require_relative '../secrets.rb' if File.exist? './config/secrets.rb'

require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|

	if ENV['RACK_ENV'] == "test" || !ENV['S3_KEY']
		config.storage = :file
		config.enable_processing = false
	else
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
        :provider              => 'AWS',
        :aws_access_key_id     => ENV['S3_KEY'],
        :aws_secret_access_key => ENV['S3_SECRET'],
        :region                => ENV['S3_REGION'],
        :path_style            => true # indispensable pour éviter l'erreur "hostname does not match the server certificate"
    }
    config.storage = :fog

    config.fog_directory    = ENV['S3_BUCKET_NAME']
    config.asset_host       = "#{ENV['S3_ASSET_URL']}/#{ENV['S3_BUCKET_NAME']}"
	end
end