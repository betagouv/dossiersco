# frozen_string_literal: true

class SuiviController < ApplicationController
  layout 'connexion'
  before_action :agent_connecté
  before_action :identification_agent, only: [:pas_encore_connectes]

  def index
    @suivi = Suivi.new

    Etablissement.all.each do |etablissement|
      if etablissement.agent.count == 1 &&
         etablissement.agent.first.jeton.present?
        @suivi.pas_encore_connecte << etablissement
      end

      if etablissement.dossier_eleve.count > 0
        @suivi.eleves_importe << etablissement
      end

      if etablissement.pieces_attendues.count > 0
        @suivi.piece_attendue_configure << etablissement
      end

      if etablissement.dossier_eleve.map(&:etat).include?('connecté')
        @suivi.familles_connectes << etablissement
      end
    end
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
