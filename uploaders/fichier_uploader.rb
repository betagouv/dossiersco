require 'carrierwave'
require 'fog-aws'

class FichierUploader  < CarrierWave::Uploader::Base
	def url
		if ENV['RACK_ENV'] == "test" || !ENV['S3_KEY']
			"/uploads/"
		else
			"http://s3.amazonaws.com/dossierscoweb/dossierscoweb/dossierscoweb/uploads/"
		end
	end
end
