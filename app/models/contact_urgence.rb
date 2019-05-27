# frozen_string_literal: true

class ContactUrgence < ActiveRecord::Base

  belongs_to :dossier_eleve

  validates :nom, presence: true, if: ->(contact) { contact.tel_secondaire.present? || contact.tel_principal.present? }

end
