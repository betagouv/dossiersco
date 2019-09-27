# frozen_string_literal: true

class ContactParEtatsController < ApplicationController

  before_action :identification_agent, except: %i[post_agent agent]
  layout "agent"

  def new
    @etats_et_emails_quantite = []

    dossiers = DossierEleve.where(etablissement: @agent_connecte.etablissement)

    DossierEleve::ETAT.each do |etat|
      nombre_de_dossiers = dossiers.where(etat: etat).count
      @etats_et_emails_quantite << ["#{nombre_de_dossiers} dossier(s) #{etat[1]}", etat[0]] if nombre_de_dossiers.positive?
    end
  end

  def create
    redirige_si_pas_de_message

    redirige_si_envoie_mail_desactive

    dossiers = DossierEleve.where(etablissement: @agent_connecte.etablissement, etat: DossierEleve::ETAT[params[:etat].to_sym])

    dossiers_sans_email = parcours_les_dossiers dossiers

    nombre_de_mail_envoye = I18n.t(".nombre_de_mail_envoye",
                                   email_envoye: (dossiers.count - dossiers_sans_email.count),
                                   dossier_sans_email: dossiers_sans_email.count)

    flash[:notice] = nombre_de_mail_envoye if dossiers_sans_email.any?

    redirect_to "/agent/liste_des_eleves"
  end

  private

  def parcours_les_dossiers(dossiers)
    dossiers_sans_email = []

    dossiers.each do |dossier|
      email = Famille.new.retrouve_un_email(dossier)

      contacter = ContacterFamille.new(dossier)
      contacter.envoyer(params[:message], email)
    rescue ExceptionAucunEmailRetrouve
      dossiers_sans_email << dossier
    end
    dossiers_sans_email
  end

  def redirige_si_pas_de_message
    return if params[:message].present?

    flash[:alert] = "Aucun texte à envoyer"
    redirect_to new_contact_par_etat_path
  end

  def redirige_si_envoie_mail_desactive
    return if @agent_connecte.etablissement.envoyer_aux_familles

    flash[:alert] = "Votre établissement est configuré pour ne pas envoyer"\
      " d'emails aux familles. Pour changer la configuration, rendez-vous"\
      " dans le module de configuration, dans le menu « configuration de"\
      " campagne » dans le bloc « accueil »."

    redirect_to new_contact_par_etat_path
  end

end
