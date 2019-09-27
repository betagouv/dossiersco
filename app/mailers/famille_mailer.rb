# frozen_string_literal: true

class FamilleMailer < ApplicationMailer

  default from: "equipe@dossiersco.fr"

  def contacter_directement_une_famille(email, message, dossier_eleve)
    @message = message
    @dossier = dossier_eleve
    email_reponse = @dossier.etablissement.email_reponse
    reply_to = if email_reponse.present?
                 email_reponse
               else
                 dossier_eleve.etablissement.email_chef
               end
    subject = "Réinscription de votre enfant au collège"

    mail(subject: subject, reply_to: reply_to, to: email, &:text)
  end

  def contacter_une_famille(dossier_eleve, agent, message)
    @dossier = dossier_eleve
    @message = message
    return unless @dossier.etablissement.envoyer_aux_familles

    begin
      email = Famille.new.retrouve_un_email(@dossier)
    rescue  ExceptionAucunEmailRetrouve
      return
    end

    subject = "Réinscription de votre enfant au collège"

    mail(subject: subject, reply_to: agent.email, to: [email, agent.email], &:text)
  end

  def envoyer_mail_confirmation(dossier_eleve)
    @dossier = dossier_eleve
    return unless @dossier.etablissement.envoyer_aux_familles

    begin
      email = Famille.new.retrouve_un_email(@dossier)
    rescue  ExceptionAucunEmailRetrouve
      return
    end

    email_reponse = @dossier.etablissement.email_reponse
    reply_to = reply_to_mail_confirmation(email_reponse, @dossier)
    mail(subject: "Réinscription de votre enfant au collège", reply_to: reply_to, to: email, &:text)
  end

  def mail_validation_inscription(dossier_eleve, agent)
    @dossier = dossier_eleve
    return unless @dossier.etablissement.envoyer_aux_familles

    begin
      email = Famille.new.retrouve_un_email(@dossier)
    rescue  ExceptionAucunEmailRetrouve
      return
    end

    subject = "Réinscription de votre enfant au collège"
    reply_to = agent.email
    mail(subject: subject, reply_to: reply_to, to: email, &:text)
  end

  private

  def reply_to_mail_confirmation(email_reponse, dossier_eleve)
    if email_reponse.present?
      email_reponse
    else
      dossier_eleve.etablissement.email_chef
    end
  end

end
