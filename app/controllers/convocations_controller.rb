# frozen_string_literal: true

class ConvocationsController < ApplicationController

  layout "agent"

  before_action :identification_agent

  def convocations
    etablissement = @agent_connecte.etablissement
    @eleves_non_inscrits = DossierEleve.pour(etablissement).a_convoquer
    @eleves_non_inscrits = @eleves_non_inscrits.paginate(page: params[:page], per_page: 10)
  end

  def generation_convocations
    etablissement = @agent_connecte.etablissement
    ConvocationJob.perform_later(etablissement, @agent_connecte)

    flash[:notice] = t(".generation_convocation")
    redirect_to convocations_etablissement_path
  end

end
