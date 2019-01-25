class DossiersAffelnetController < ApplicationController
  layout 'agent'

  before_action :identification_agent

  def create
    DossierAffelnet.where(etablissement: @agent.etablissement).destroy_all
    tempfile = params[:fichier].tempfile
    @nom_fichier = params[:fichier].original_filename
    xls_document = Roo::Spreadsheet.open tempfile
    xls_document.sheet(0).each do |hash|
      DossierAffelnet.create!(
        etablissement: @agent.etablissement,
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
    @nombre_de_lignes = DossierAffelnet.count
    render :traitement_import
  end
end
