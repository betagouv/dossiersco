# frozen_string_literal: true

class ConfigurationsController < ApplicationController
  layout 'configuration'

  before_action :identification_agent
  before_action :if_agent_is_admin

  def show
    etablissement = @agent_connecté.etablissement
    stats = Struct.new(:agents, :options, :mef, :dossiers, :date_fin, :uai, :nom_etablissement, :code_postal,
                       :pieces_attendues, :eleves_sans_mef)
    @stats = stats.new
    @stats.agents = Agent.where(etablissement: etablissement).count
    @stats.options = etablissement.options_pedagogiques.count
    @stats.mef = etablissement.mef.count
    @stats.eleves_sans_mef = etablissement.dossier_eleve.where(mef_origine: nil).count
    @stats.dossiers = etablissement.dossier_eleve.count
    @stats.date_fin = etablissement.date_limite
    @stats.uai = etablissement.uai
    @stats.nom_etablissement = etablissement.nom
    @stats.code_postal = etablissement.code_postal
    @stats.pieces_attendues = etablissement.pieces_attendues.map(&:nom)
  end
end
