class TacheImportsController < ApplicationController
  before_action :identification_agent
  layout 'agent'

  def create
    tache_import = TacheImport.create!(tache_import_params.merge(etablissement: agent_connecté.etablissement))
    TraiterImportsJob.perform_later tache_import.id

    redirect_to '/agent/import_siecle'
  end

  private
  def tache_import_params
    params.require(:tache_import).permit(:fichier)
  end
end
