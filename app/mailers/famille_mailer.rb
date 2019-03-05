class FamilleMailer < ApplicationMailer
  default from: "contact@dossiersco.fr"
  default reply_to: "contact@dossiersco.fr"

  def contacter_une_famille(eleve, message)
    @eleve = eleve
    @message = message

    etablissement = @eleve.dossier_eleve.etablissement
    emails = ['contact@dossiersco.fr']
    if etablissement.envoyer_aux_familles
      emails += @eleve.dossier_eleve.resp_legal.map{ |resp_legal| resp_legal.email }
    end

    mail(subject: "Réinscription de votre enfant au collège", reply_to: ['contact@dossiersco.fr', @eleve.dossier_eleve.etablissement.email], to: emails) do |format|
      format.text
    end
  end

  def envoyer_mail_confirmation(eleve)
    contacter_une_famille eleve, ''
  end

  def mail_validation_inscription(eleve)
    contacter_une_famille eleve, ''
  end

  # avant, ça envoyais à etablissement.email en plus...
  def message_differe(eleve, contenu)

    etablissement = eleve.dossier_eleve.etablissement
    emails = ['contact@dossiersco.fr', etablissement.email_chef]
    if etablissement.envoyer_aux_familles
      resp_legal = eleve.dossier_eleve.resp_legal_1
      emails += [resp_legal.email]
    end

    mail(subject: "Réinscription de votre enfant au collège", reply_to: ['contact@dossiersco.fr', etablissement.email_chef], to: emails) do |format|
      format.text { render plain: contenu }
    end
  end

  # Utilisée ponctuellement en juin 2018 pour "doubler" une diffusion par cartable
  # d'un contact mail, restreint au 1er RL car nous donnons l'INE et contacter les 2
  # parents n'aurait pas les mêmes caractéristiques que la diffusion par cartable du
  # point de vue sécurité; ne met pas l'établissement en copie pour ne pas les spammer
  def invitations_parents(eleve)
    @eleve = eleve

    etablissement = eleve.dossier_eleve.etablissement
    emails = ['contact@dossiersco.fr']
    if etablissement.envoyer_aux_familles
      emails += [eleve.dossier_eleve.resp_legal.first.email]
    end

    mail(subject: "Réinscription de votre enfant au collège",
         reply_to: ['contact@dossiersco.fr', @eleve.dossier_eleve.etablissement.email_chef], to: emails) do |format|
      format.text
    end
  end


end

