class TacheImport < ActiveRecord::Base
  belongs_to :etablissement

  mount_uploader :fichier, ImportUploader

end
