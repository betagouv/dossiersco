class TacheImportsController < ApplicationController
  before_action :identification_agent
  layout 'agent'

  def create
    tempfile = tache_import_params[:fichier].tempfile

    import_xls tempfile, agent_connecté.etablissement.id
    redirect_to '/agent/import_siecle'
  end

  private
  def tache_import_params
    params.require(:tache_import).permit(:fichier)
  end
end