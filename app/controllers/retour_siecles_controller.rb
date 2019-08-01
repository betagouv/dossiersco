# frozen_string_literal: true

class RetourSieclesController < ApplicationController

  layout "configuration"

  before_action :identification_agent
  before_action :if_agent_is_admin

  def new
    @tache = agent_connecte.etablissement.tache_import.last || TacheImport.new(etablissement: agent_connecte.etablissement)

    render(:manque_code_matiere) && return if OptionPedagogique.where(etablissement: @etablissement, code_matiere_6: nil).count.positive?

    @dossiers = DossierEleve.where(etablissement: @etablissement).where("mef_destination_id is not null")

    if params[:liste_ine].present?
      ines = params[:liste_ine].split(",")
      @selection_dossiers = @dossiers.joins(:eleve).where("eleves.identifiant in (?)", ines)
    end
  end

end
