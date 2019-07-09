# frozen_string_literal: true

class SuiviController < ApplicationController

  layout "connexion"
  before_action :agent_connecte
  before_action :identification_agent, only: [:pas_encore_connectes]

  def index
    @suivi = Suivi.new

    Etablissement.where.not("nom like ?", "%test%").each do |etablissement|
      nb_familles_connectees = etablissement.dossier_eleve.reject { |d| d.etat == "pas connecté" }.length
      if nb_familles_connectees.positive?
        @suivi.familles_connectes << { etablissement: etablissement, nb_familles_connectees: nb_familles_connectees }
      elsif etablissement.dossier_eleve.count.positive?
        @suivi.eleves_importe << etablissement
      else
        @suivi.pas_encore_connecte << etablissement
      end
    end
    @suivi.familles_connectes.sort_by! { |obj| obj[:nb_familles_connectees] }.reverse!
  end

  def etablissements_experimentateurs
    @etablissements = Etablissement.where.not("nom like ?", "%test%").order(:code_postal)
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
