class AgentMailer < ApplicationMailer
    default from: "contact@dossiersco.fr"

    def emails
        @eleve.dossier_eleve.resp_legal.map{ |resp_legal| resp_legal.email } +
            ['contact@dossiersco.fr']
    end

    def contacter_une_famille(eleve, message)
        @message = message
        @eleve = eleve
        mail(subject: "Réinscription de votre enfant au collège",
            reply_to: ['contact@dossiersco.fr', @eleve.dossier_eleve.etablissement.email],
            to: emails) do |format|
                format.text
            end
    end

    def envoyer_mail_confirmation(eleve)
        contacter_une_famille eleve, ''
    end

    def mail_validation_inscription(eleve)
        contacter_une_famille eleve, ''
    end

    def message_differe(eleve, contenu)
        etablissement = eleve.dossier_eleve.etablissement
        resp_legal = eleve.dossier_eleve.resp_legal_1
        mail(subject: "Réinscription de votre enfant au collège",
            reply_to:['contact@dossiersco.fr', etablissement.email],
            to: ['contact@dossiersco.fr', resp_legal.email, etablissement.email]) do |format|
                format.text { render plain: contenu }
            end
    end

    # Utilisée ponctuellement en juin 2018 pour "doubler" une diffusion par cartable
    # d'un contact mail, restreint au 1er RL car nous donnons l'INE et contacter les 2
    # parents n'aurait pas les mêmes caractéristiques que la diffusion par cartable du
    # point de vue sécurité; ne met pas l'établissement en copie pour ne pas les spammer
    def invitations_parents(eleve)
        @eleve = eleve
        destinataires = [eleve.dossier_eleve.resp_legal.first.email, 'contact@dossiersco.fr']
        mail(subject: "Réinscription de votre enfant au collège",
            reply_to: ['contact@dossiersco.fr', @eleve.dossier_eleve.etablissement.email],
            to: destinataires) do |format|
                format.text
            end
    end

  def succes_import(email, statistiques)
    @statistiques = statistiques
    mail(subject: "Import de votre base élève dans DossierSCO",
         reply_to: 'contact@dossiersco.fr',
         to: email) do |format|
      format.text
    end
  end

  def erreur_import(email)
    mail(subject: "L'import de votre base élève a échoué",
         reply_to: 'contact@dossiersco.fr',
         to: email) do |format|
      format.text
    end
  end
end
