# frozen_string_literal: true

class Eleve < ActiveRecord::Base

  has_one :dossier_eleve, dependent: :destroy
  has_many :demande
  has_many :abandon
  # TODO : faire un remove_column de montee_id
  belongs_to :montee, required: false
  delegate :email_resp_legal_1, to: :dossier_eleve

end
