class AgentMailer < ApplicationMailer
  default from: "equipe@dossiersco.fr",
    reply_to: "equipe@dossiersco.fr"

  def succes_import(email, statistiques)
    @statistiques = statistiques
    mail(subject: "Import de votre base élève dans DossierSCO", to: email) do |format|
      format.text
    end
  end

  def erreur_import(email)
    mail(subject: "L'import de votre base élève a échoué", to: email) do |format|
      format.text
    end
  end

  def invite_premier_agent(agent)
    @agent = agent
    mail(subject: "Activez votre compte DossierSCO", to: @agent.email) do |format|
      format.html
      format.text
    end
  end

  def invite_agent(agent_invite, admin)
    @agent_invite = agent_invite
    @admin = admin
    mail(subject: "Activez votre compte agent sur DossierSCO", to: @agent_invite.email) do |format|
      format.html
      format.text
    end
  end
end
