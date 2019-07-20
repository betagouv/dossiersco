# frozen_string_literal: true

class RetourSieclesController < ApplicationController

  layout "configuration"

  before_action :identification_agent
  before_action :if_agent_is_admin

  def new
    @tache = agent_connecte.etablissement.tache_import.last || TacheImport.new(etablissement: agent_connecte.etablissement)

    render(:manque_code_matiere) && return if OptionPedagogique.where(etablissement: @etablissement, code_matiere_6: nil).count.positive?

    @dossiers = DossierEleve.where(etablissement: @etablissement)
    ines = params[:liste_ine].split(",")
    @selection_dossiers = @etablissement.dossier_eleve.joins(:eleve).where("eleves.identifiant in (?)", ines) if params[:liste_ine].present?
  end

end
