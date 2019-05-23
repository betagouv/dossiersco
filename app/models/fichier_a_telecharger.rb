# frozen_string_literal: true

class FichierATelecharger < ApplicationRecord

  belongs_to :etablissement

  mount_uploader :contenu, FichierATelechargerUploader

end
