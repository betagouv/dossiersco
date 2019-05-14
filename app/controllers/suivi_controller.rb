# frozen_string_literal: true

class SuiviController < ApplicationController

  layout "connexion"
  before_action :agent_connecte
  before_action :identification_agent, only: [:pas_encore_connectes]

  def index
    @suivi = Suivi.new

    Etablissement.all.each do |etablissement|
      if etablissement.agent.count == 1 &&
         etablissement.agent.first.jeton.present?
        @suivi.pas_encore_connecte << etablissement
      end

      @suivi.eleves_importe << etablissement if etablissement.dossier_eleve.count.positive?

      @suivi.piece_attendue_configure << etablissement if etablissement.pieces_attendues.count.positive?

      @suivi.familles_connectes << etablissement if etablissement.dossier_eleve.map(&:etat).include?("connecté")
    end
  end

  def etablissements_experimentateurs
    @etablissements = Etablissement.where.not("nom like ?", "%test").order(:code_postal)
  end

end

class Suivi

  attr_accessor :pas_encore_connecte, :eleves_importe, :piece_attendue_configure, :familles_connectes

  def initialize
    @pas_encore_connecte = []
    @eleves_importe = []
    @piece_attendue_configure = []
    @familles_connectes = []
  end

end
