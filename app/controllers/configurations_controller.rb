# frozen_string_literal: true

class ConfigurationsController < ApplicationController

  layout "configuration"

  before_action :identification_agent
  before_action :if_agent_is_admin

  Stats = Struct.new(:agents, :options, :mef, :dossiers, :date_fin, :uai, :nom_etablissement, :code_postal,
                     :pieces_attendues, :eleves_sans_mef, keyword_init: true)

  def show
    etablissement = @agent_connecte.etablissement
    @stats = Stats.new(agents: Agent.pour_etablissement(agent_connecte.etablissement).count,
                       options: etablissement.options_pedagogiques.count, mef: etablissement.mef.count,
                       eleves_sans_mef: etablissement.dossier_eleve.where(mef_origine: nil).count,
                       dossiers: etablissement.dossier_eleve.count, date_fin: etablissement.date_limite,
                       uai: etablissement.uai, nom_etablissement: etablissement.nom,
                       code_postal: etablissement.code_postal, pieces_attendues: etablissement.pieces_attendues.map(&:nom))
  end

end
