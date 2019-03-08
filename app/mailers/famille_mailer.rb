class FamilleMailer < ApplicationMailer
  default from: "equipe@dossiersco.fr"

  def contacter_une_famille(eleve, agent, message)
    @eleve = eleve
    @message = message

    etablissement = @eleve.dossier_eleve.etablissement
    emails = [agent.email]

    if etablissement.envoyer_aux_familles
      emails += [@eleve.dossier_eleve.resp_legal.find_by(priorite: 1).email]
    end

    subject = "Réinscription de votre enfant au collège"
    reply_to = agent.email

    mail(subject: subject, reply_to: reply_to, to: emails) do |format|
      format.text
    end
  end

  def envoyer_mail_confirmation(eleve)
    @eleve = eleve
    etablissement = @eleve.dossier_eleve.etablissement
    return unless etablissement.envoyer_aux_familles


    email = @eleve.dossier_eleve.resp_legal.find_by(priorite: 1).email
    subject = "Réinscription de votre enfant au collège"
    reply_to = @eleve.dossier_eleve.etablissement.email_chef

    mail(subject: subject, reply_to: reply_to, to: email) do |format|
      format.text
    end
  end

  def mail_validation_inscription(eleve, agent)
    @eleve = eleve
    etablissement = @eleve.dossier_eleve.etablissement

    if etablissement.envoyer_aux_familles
      email = @eleve.dossier_eleve.resp_legal.find_by(priorite: 1).email
    else
      email = agent.email
    end

    subject = "Réinscription de votre enfant au collège"
    reply_to = agent.email

    mail(subject: subject, reply_to: reply_to, to: email) do |format|
      format.text
    end
  end

end

