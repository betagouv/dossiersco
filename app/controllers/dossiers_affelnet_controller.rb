# frozen_string_literal: true

class DossiersAffelnetController < ApplicationController

  layout "agent"

  before_action :identification_agent

  def create
    if params[:fichier].present?
      DossierAffelnet.where(etablissement: agent_connecte.etablissement).destroy_all
      tempfile = params[:fichier].tempfile
      @nom_fichier = params[:fichier].original_filename
      xls_document = Roo::Spreadsheet.open tempfile
      xls_document.sheet(0).each do |hash|
        next if hash[0] == "Nom"

        DossierAffelnet.create!(
          etablissement: agent_connecte.etablissement,
          nom: hash[0],
          prenom: hash[1],
          date_naissance: hash[2],
          etablissement_origine: hash[3],
          etablissement_accueil: hash[4],
          rang: hash[5],
          dérogation: hash[6],
          formation_accueil: hash[7],
          decision_de_passage: hash[8]
        )
      end
      @nombre_de_lignes = DossierAffelnet.where(etablissement: agent_connecte.etablissement).count
      render :traitement_import
    else
      flash[:alert] = t("inscriptions.import_siecle.fichier_manquant")
      redirect_to agent_import_siecle_path
    end
  end

  def traiter
    @nom_fichier = "perdu en route"
    @nombre_de_lignes = DossierAffelnet.where(etablissement: agent_connecte.etablissement).count
    render :traitement_import
  end

end
