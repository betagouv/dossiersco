# frozen_string_literal: true

class ContacterFamille

  def initialize(dossier, expediteur)
    @emails_presents = false
    @portable_presents = false
    resp_legaux = dossier.resp_legal
    resp_legaux.each do |r|
      @emails_presents = r.email.present?
      @portable_presents = r.tel_portable.present?
    end
    raise ErreurMoyenDeContactNonTrouve, "aucun moyen de contact trouvé pour ce responsable légal" unless @emails_presents || @portable_presents

    @dossier = dossier
    @eleve = dossier.eleve
    @expediteur = expediteur
  end

  def envoyer(message)
    if @emails_presents
      mail = FamilleMailer.contacter_une_famille(@eleve, @expediteur, message)
      part = mail.html_part || mail.text_part || mail
      msg = Message.create(categorie: "mail", contenu: part.body, etat: "envoyé", dossier_eleve: @dossier)
      mail.deliver_now
    elsif @dossier.portable_rl1.present?
      msg = Message.create(categorie: "sms", contenu: message, destinataire: @eleve || "rl1", etat: "en attente", dossier_eleve: @dossier)
    end
    msg
  end

end

class ErreurMoyenDeContactNonTrouve < RuntimeError; end
