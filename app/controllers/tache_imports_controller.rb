class TacheImportsController < ApplicationController
  before_action :identification_agent
  layout 'agent'

  def create
    tache = TacheImport.create!(tache_import_params.merge({etablissement: agent_connecté.etablissement, statut: 'en_attente'}))
    redirect_to '/agent/import_siecle'
  end

  private
  def tache_import_params
    params.require(:tache_import).permit(:fichier)
  end
end