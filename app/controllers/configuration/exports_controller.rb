module Configuration
  class ExportsController < ApplicationController
    before_action :if_agent_is_admin

    def export_options
      @lignes = faire_lignes
      respond_to do |format|
        format.xlsx
      end
    end

    private

    def faire_lignes
      options_etablissement = @agent_connecté.etablissement.options_pedagogiques
      entet_options = options_etablissement.map(&:nom)
      @entete = ['classe actuelle', 'MEF actuel', 'prenom', 'nom', 'date naissance', 'sexe'].concat(entet_options)
      @lignes = []
      DossierEleve.where(etablissement: @agent_connecté.etablissement).each do |dossier|
        options_eleve = []
        options_etablissement.each do |option|
          options_eleve << (dossier.options_pedagogiques.include?(option) ? 'X' : '')
        end
        mef_origin = dossier.mef_origine.present? ? dossier.mef_origine.libelle : ''
        @lignes << [dossier.eleve.classe_ant, mef_origin, dossier.eleve.prenom, dossier.eleve.nom,
                    dossier.eleve.date_naiss, dossier.eleve.sexe].concat(options_eleve)
      end
      @lignes
    end
  end
end