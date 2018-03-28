require 'carrierwave'

class FichierUploader  < CarrierWave::Uploader::Base
	storage :file
end