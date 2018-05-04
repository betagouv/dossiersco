require 'carrierwave'
require 'fog-aws'

class FichierUploader  < CarrierWave::Uploader::Base
  def self.route_lecture
    if ENV['RACK_ENV'] == "test" || !ENV['S3_KEY']
      "/uploads"
    else
      "/piece"
    end
  end
end
