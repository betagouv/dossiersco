# frozen_string_literal: true

class ContacterFamille

  def initialize(eleve)
    @dossier = eleve.dossier_eleve
  end

  def envoyer(message, moyen)
    moyen = moyen.delete(" ")

    if email?(moyen)
      msg = envoyer_email(message, moyen)
    else
      moyen = ajoute_code_pays(moyen)
      msg = envoyer_sms(message, moyen)
    end
    msg
  end

  def envoyer_email(message, moyen)
    mail = FamilleMailer.contacter_directement_une_famille(moyen, message, @dossier.eleve)
    part = mail.html_part || mail.text_part || mail
    mail.deliver_now
    Message.create(categorie: "mail", contenu: part.body, destinataire: moyen, etat: "envoyé", dossier_eleve: @dossier)
  end

  def envoyer_sms(message, moyen)
    textoer = FamilleTextoer.new
    textoer.envoyer_message(moyen, message)
    Message.create(categorie: "sms", contenu: message, destinataire: moyen, etat: "envoyé", dossier_eleve: @dossier)
  end

  def email?(contact)
    contact.index("@").present?
  end

  def ajoute_code_pays(numero)
    if numero.length == 11 && numero[0..1] == "33"
      numero
    else
      "33" + numero[1..]
    end
  end

end
