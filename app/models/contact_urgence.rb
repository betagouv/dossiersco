# frozen_string_literal: true

class ContactUrgence < ActiveRecord::Base

  belongs_to :dossier_eleve

  validates :nom, presence: true
  validates :tel_principal, presence: true, if: ->(contact) { contact.tel_secondaire.blank? }
  validates :tel_secondaire, presence: true, if: ->(contact) { contact.tel_principal.blank? }

end
