# frozen_string_literal: true

module Configuration
  class DossiersEleveController < ApplicationController

    before_action :identification_agent
    before_action :if_agent_is_admin, except: %i[edit update activation]

    def changer_mef_destination
      dossiers = DossierEleve.where(etablissement: @agent_connecte.etablissement, mef_origine: params[:mef_origine])
      dossiers.update_all(mef_destination_id: params[:nouveau_mef_destination])

      dossiers.each do |dossier_eleve|
        mef_destination = dossier_eleve.mef_destination
        dossier_eleve.options_pedagogiques &= mef_destination.options_pedagogiques

        options_origines = dossier_eleve.options_origines.keys.map { |o| OptionPedagogique.find(o) }
        options_origines.each do |option|
          dossier_eleve.options_pedagogiques << option if !option.abandonnable?(dossier_eleve.mef_destination) && !dossier_eleve.options_pedagogiques.include?(option) && mef_destination.options_pedagogiques.include?(option)
        end
      end

      redirect_to configuration_mef_index_path
    end

  end
end
