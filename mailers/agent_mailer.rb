class AgentMailer < ActionMailer::Base
    default from: "contact@dossiersco.beta.gouv.fr"

    def emails
        @eleve.dossier_eleve.resp_legal.map{ |resp_legal| resp_legal.email } + ['contact@dossiersco.beta.gouv.fr']
    end

    def contacter_une_famille(eleve, message)
        @message = message
        @eleve = eleve
        mail(subject: "Réinscription de votre enfant au collège", to: emails) do |format|
            format.text
        end
    end

    def envoyer_mail_confirmation(eleve)
        @eleve = eleve
        mail(subject: "Réinscription de votre enfant au collège", to: emails) do |format|
            format.text
        end
    end

    def mail_validation_inscription(eleve)
        @eleve = eleve
        mail(subject: "Réinscription de votre enfant au collège", to: emails) do |format|
            format.text
        end
    end

end
