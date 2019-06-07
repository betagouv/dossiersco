# frozen_string_literal: true

class ContacterFamille

  def initialize(eleve)
    @dossier = eleve.dossier_eleve
  end

  def envoyer(message, moyen)
    if email?(moyen)
      envoyer_email(message, moyen)
    else
      envoyer_sms(message, moyen)
    end
  end

  def envoyer_email(message, moyen)
    mail = FamilleMailer.contacter_directement_une_famille(moyen, message)
    part = mail.html_part || mail.text_part || mail
    mail.deliver_now
    msg = Message.create(categorie: "mail", contenu: part.body, etat: "envoyé", dossier_eleve: @dossier)
  end

  def envoyer_sms(message, moyen)
    msg = Message.create(categorie: "sms", contenu: message, destinataire: "rl1", etat: "en attente", dossier_eleve: @dossier)
  end

  def email?(contact)
    begin
      Integer(contact)
      false
    rescue
      true
    end
  end
end
