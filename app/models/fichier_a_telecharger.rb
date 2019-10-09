# frozen_string_literal: true

class FichierATelecharger < ApplicationRecord

  belongs_to :etablissement

  mount_uploader :contenu, FichierATelechargerUploader

  scope :de_type_changement, lambda { |etablissement|
    where(nom: "changements", etablissement: etablissement)
      .order("created_at DESC")
  }

  scope :de_type_eleve, lambda { |etablissement|
    where(nom: "eleves", etablissement: etablissement)
      .order("created_at DESC")
  }

  scope :de_type_piece, lambda { |etablissement|
    where(nom: "pieces-jointes", etablissement: etablissement)
      .order("created_at DESC")
  }

end
