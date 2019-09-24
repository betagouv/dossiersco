# frozen_string_literal: true

class RelancerDossier

  def initialize(etablissement)
    @etablissement = etablissement
  end

  def par_email(etat)
    dossiers = DossierEleve.where(etablissement: @etablissement, etat: etat)

    dossiers.each do |dossier|
    end

    unless params[:message].present?
      flash[:alert] = "Aucun texte à envoyer"
      redirect_to "/agent/eleve/#{dossier.identifiant}#echanges"
      return
    end
    unless params[:moyen_de_communication].present?
      flash[:alert] = "Aucun moyen de communication choisi"
      redirect_to "/agent/eleve/#{dossier.identifiant}#echanges"
      return
    end
    unless @agent_connecte.etablissement.envoyer_aux_familles
      flash[:alert] = I18n.t(".alert_pas_config_envoyer_email")
      redirect_to "/agent/eleve/#{dossier.identifiant}#echanges"
      return
    end

    contacter = ContacterFamille.new(dossier.eleve)
    contacter.envoyer(params[:message], params[:moyen_de_communication])
  end

end
