# frozen_string_literal: true

class ApplicationController < ActionController::Base

  def retrouve_eleve_connecte
    @eleve ||= Eleve.find_by(identifiant: session[:identifiant])
    if @eleve
      ajoute_information_utilisateur_pour_sentry(
        type_utilisateur: "famille",
        dossiersco_id: @eleve.id
      )
    else
      session[:message_erreur] = "Vous avez été déconnecté par mesure de sécurité. Merci de vous identifier avant de continuer."
      redirect_to "/"
    end
  end

  def agent_connecte
    @agent_connecte ||= if params[:jeton]
                          Agent.find_by(jeton: params[:jeton])
                        else
                          Agent.find_by(email: session[:agent_email])
                        end
    @etablissement = @agent_connecte.etablissement if @agent_connecte
    @agent_connecte
  end

  def identification_agent
    unless agent_connecte.present?
      redirect_to "/agent", alert: t("messages.probleme_identification")
      return
    end
    ajoute_information_utilisateur_pour_sentry(
      type_utilisateur: "agent",
      dossiersco_id: agent_connecte.id
    )
    Trace.create(identifiant: agent_connecte.email,
                 categorie: "agent",
                 page_demandee: request.path_info,
                 adresse_ip: request.ip)
  end

  def if_agent_is_admin
    if !agent_connecte.nil? && !agent_connecte.admin?
      redirect_to agent_tableau_de_bord_path
    elsif agent_connecte.nil?
      redirect_to root_path
    end
  end

  private

  def ajoute_information_utilisateur_pour_sentry(infos)
    Raven.tags_context(type_utilisateur: infos[:type_utilisateur], dossiersco_id: infos[:dossiersco_id])
  end

end
