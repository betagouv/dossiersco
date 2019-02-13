class TacheImportsController < ApplicationController
  before_action :identification_agent
  layout 'agent'

  def create
    if params[:tache_import].present?
      tache_import = TacheImport.create(tache_import_params.merge(etablissement: agent_connecté.etablissement))
      tache_import.job_klass.constantize.send(:perform_later, tache_import.id, agent_connecté.email)
      flash[:notice] = t('inscriptions.import_siecle.message_de_succes', email: agent_connecté.email)
    else
      flash[:alert] = t('inscriptions.import_siecle.fichier_manquant')
    end
    redirect_to agent_import_siecle_path
  end

  private
  def tache_import_params
    params.require(:tache_import).permit(:fichier, :job_klass)
  end
end
