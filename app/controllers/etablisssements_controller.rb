class EtablisssementsController < ApplicationController
  before_action :identification_agent
  before_action :if_agent_is_admin
  layout 'layout_configuration'

  def new
    @etablissement = Etablissement.new
  end

  def create
    @etablissement = Etablissement.new(etablissement_params)

    if @etablissement.save
      redirect_to configuration_path
    else
      render :new
    end
  end

  private
  def etablissement_params
    params.require(:etablissement).permit(:nom, :email, :adresse, :ville, :code_postal, :message_permanence,
                                               :message_infirmerie, :gere_demi_pension, :signataire)
  end
end
