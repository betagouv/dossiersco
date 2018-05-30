class AgentMailer < ActionMailer::Base
    default from: "contact@dossiersco.beta.gouv.fr"
    default to: "lucien.mollard@beta.beta.gouv.fr"

    def contacter_une_famille(message, emails)
        @message = message
        mail(subject: "TODO", to: emails) do |format|
            format.text
        end
    end

    def mail_validation_inscription(emails, eleve)
        @eleve = eleve
        mail(subject: "Validation d'inscription", to: emails) do |format|
            format.text
        end
    end

    def envoyer_mail_confirmation(emails, eleve)
        @eleve = eleve
        mail(subject: "Validation de demande d'inscription", to: emails) do |format|
            format.text
        end
    end
end