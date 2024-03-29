# frozen_string_literal: true

class FichesInfirmeriesController < ApplicationController

  layout "agent"

  before_action :identification_agent

  def fiches_infirmeries
    @fichiers_infirmerie = FichierATelecharger
                           .where(nom: "PdfFicheInfirmerie", etablissement: @agent_connecte.etablissement)
                           .order("created_at DESC")
  end

  def generation_fiches_infirmerie
    etablissement = @agent_connecte.etablissement
    FicheInfirmerieJob.perform_later(etablissement, @agent_connecte)

    flash[:notice] = t(".generation_fiche_infirmerie")
    redirect_to fiches_infirmeries_etablissement_path
  end

end
