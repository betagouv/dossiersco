# frozen_string_literal: true

module Configuration
  class DossiersEleveController < ApplicationController

    before_action :identification_agent
    before_action :if_agent_is_admin, except: %i[edit update activation]

    def changer_mef_destination
      dossiers = DossierEleve.where(etablissement: @agent_connecte.etablissement, mef_origine: params[:mef_origine])

      puts dossiers.inspect

      dossiers.update_all(mef_destination_id: params[:nouveau_mef_destination])

      dossiers = DossierEleve.where(etablissement: @agent_connecte.etablissement, mef_origine: params[:mef_origine])

      puts dossiers.inspect

      redirect_to configuration_mef_index_path
    end

  end
end
