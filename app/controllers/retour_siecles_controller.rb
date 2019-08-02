# frozen_string_literal: true

class RetourSieclesController < ApplicationController

  layout "configuration"

  before_action :identification_agent
  before_action :if_agent_is_admin

  def new
    @tache = agent_connecte.etablissement.tache_import.last || TacheImport.new(etablissement: agent_connecte.etablissement)

    render(:manque_code_matiere) && return if OptionPedagogique.where(etablissement: @etablissement, code_matiere_6: nil).count.positive?

    @dossiers = dossiers_etablissement.where("mef_destination_id is not null")
    @dossiers_sans_mef_destination = dossiers_etablissement.where(mef_destination: nil)
    @dossiers_sans_nom_ou_prenom = eleves_sans_nom.or(eleves_sans_prenom)

    if params[:liste_ine].present?
      ines = params[:liste_ine].split(",")
      @selection_dossiers = @dossiers.joins(:eleve).where("eleves.identifiant in (?)", ines)
    end
  end

  def dossiers_etablissement
    DossierEleve.where(etablissement: @etablissement)
  end

  def eleves_sans_prenom
    dossiers_etablissement.joins(:eleve).where("eleves.prenom is null")
  end

  def eleves_sans_nom
    dossiers_etablissement.joins(:eleve).where("eleves.nom is null")
  end

end
