# frozen_string_literal: true

class FichesInfirmeriesController < ApplicationController

  layout "agent"

  before_action :identification_agent

  def fiches_infirmeries; end

  def generation_fiches_infirmerie
    etablissement = @agent_connecte.etablissement
    FicheInfirmerieJob.perform_later(etablissement, @agent_connecte)

    flash[:notice] = t(".generation_fiche_infirmerie")
    redirect_to convocations_etablissement_path
  end

end
