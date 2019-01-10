require 'carrierwave'
require 'fog-aws'

class FichierUploader  < CarrierWave::Uploader::Base
  def self.route_lecture dossier_eleve_id, code_piece
    if ENV['RACK_ENV'] == "test" || !ENV['S3_KEY']
      "/uploads"
    else
      "/piece/#{dossier_eleve_id}/#{code_piece}"
    end
  end
end
