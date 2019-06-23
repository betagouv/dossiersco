# frozen_string_literal: true

class FamilleMailer < ApplicationMailer

  default from: "equipe@dossiersco.fr"

  def contacter_directement_une_famille(email, message, eleve)
    @message = message
    @eleve = eleve
    email_reponse = @eleve.dossier_eleve.etablissement.email_reponse
    reply_to = if email_reponse.present?
                 email_reponse
               else
                 eleve.dossier_eleve.etablissement.email_chef
               end
    subject = "Réinscription de votre enfant au collège"

    mail(subject: subject, reply_to: reply_to, to: email, &:text)
  end

  def contacter_une_famille(eleve, agent, message)
    @eleve = eleve
    @message = message
    return unless @eleve.dossier_eleve.etablissement.envoyer_aux_familles

    begin
      email = Famille.new.retrouve_un_email(@eleve.dossier_eleve)
    rescue  ExceptionAucunEmailRetrouve
      return
    end

    subject = "Réinscription de votre enfant au collège"
    reply_to = agent.email

    mail(subject: subject, reply_to: reply_to, to: [email, agent.email], &:text)
  end

  def envoyer_mail_confirmation(eleve)
    @eleve = eleve
    return unless @eleve.dossier_eleve.etablissement.envoyer_aux_familles

    begin
      email = Famille.new.retrouve_un_email(@eleve.dossier_eleve)
    rescue  ExceptionAucunEmailRetrouve
      return
    end

    subject = "Réinscription de votre enfant au collège"
    email_reponse = @eleve.dossier_eleve.etablissement.email_reponse
    reply_to = if email_reponse.present?
                 email_reponse
               else
                 eleve.dossier_eleve.etablissement.email_chef
               end
    mail(subject: subject, reply_to: reply_to, to: email, &:text)
  end

  def mail_validation_inscription(eleve, agent)
    @eleve = eleve
    return unless @eleve.dossier_eleve.etablissement.envoyer_aux_familles

    begin
      email = Famille.new.retrouve_un_email(@eleve.dossier_eleve)
    rescue  ExceptionAucunEmailRetrouve
      return
    end

    subject = "Réinscription de votre enfant au collège"
    reply_to = agent.email
    mail(subject: subject, reply_to: reply_to, to: email, &:text)
  end

end
