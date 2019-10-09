# frozen_string_literal: true

class TacheImportsController < ApplicationController

  before_action :identification_agent
  layout "configuration"

  def new
    @tache = agent_connecte.etablissement.tache_import.last || TacheImport.new(etablissement: agent_connecte.etablissement)
    @fichiers_changements_a_telecharger = FichierATelecharger.de_type_changement(agent_connecte.etablissement)
    @fichiers_a_telecharger = FichierATelecharger.de_type_eleve(agent_connecte.etablissement)
    @pieces_a_telecharger = FichierATelecharger.de_type_piece(agent_connecte.etablissement)
    @mef = agent_connecte.etablissement.mef
  end

  def create
    tache = TacheImport .find_by(etablissement: agent_connecte.etablissement,
                                 statut: [TacheImport::STATUTS[:en_attente], TacheImport::STATUTS[:en_traitement]])

    if tache.present?
      flash[:alert] = t(".tache_deja_en_traitement")
    elsif params[:tache_import].present?
      importer_dans_siecle
    else
      flash[:alert] = t(".fichier_manquant")
    end

    redirect_back(fallback_location: new_tache_import_path)
  end

  private

  def importer_dans_siecle
    tache_import = TacheImport.create(tache_import_params.merge(etablissement: agent_connecte.etablissement,
                                                                statut: TacheImport::STATUTS[:en_attente]))
    ImporterSiecle.perform_later(tache_import.id, agent_connecte.email)
    flash[:notice] = t(".message_de_succes", email: agent_connecte.email)
  end

  def tache_import_params
    params.require(:tache_import).permit(:fichier, :type_fichier)
  end

end
