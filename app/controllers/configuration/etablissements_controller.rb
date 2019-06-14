# frozen_string_literal: true

module Configuration
  class EtablissementsController < ApplicationController

    layout "configuration"

    before_action :if_agent_is_admin, except: %i[new create relance_invitation_agent]
    before_action :cherche_etablissement, only: %i[show edit update relance_invitation_agent]

    def index
      @etablissements = Etablissement.all.order(:nom)
      render layout: "connexion"
    end

    def show; end

    def new
      @etablissement = Etablissement.find_by(uai: params[:uai])
      render layout: "connexion"
    end

    def create
      agent = EnregistrementPremierAgentService.new.execute(etablissement_params[:uai])
      PrerempliEtablissement.perform_later(agent.etablissement.uai)
      redirect_to new_configuration_etablissement_path, notice: t(".mail_envoye", mail_ce: agent.email)
    rescue StandardError => error
      flash[:error] = t(".#{error}")
      redirect_to new_configuration_etablissement_path(uai: etablissement_params[:uai])
    end

    def edit; end

    def update
      if @etablissement.update(etablissement_params)
        redirect_to configuration_etablissement_path(@etablissement)
      else
        render :edit
      end
    end

    def purge
      agent_connecte.etablissement.purge_dossiers_eleves!
      redirect_to new_tache_import_path, notice: t(".purge_succes")
    end

    def relance_invitation_agent
      agent = @etablissement.agent.first
      AgentMailer.invite_premier_agent(agent).deliver_now
      redirect_to new_configuration_etablissement_path, notice: t(".mail_envoye", mail_ce: agent.email)
    end

    private

    def etablissement_params
      params.require(:etablissement).permit(:nom, :email, :adresse, :ville, :code_postal,
                                            :gere_demi_pension, :signataire, :date_limite, :uai,
                                            :envoyer_aux_familles, :reglement_demi_pension, :mot_accueil,
                                            :demande_caf)
    end

    def cherche_etablissement
      @etablissement = if params[:id].present?
                         Etablissement.find(params[:id])
                       elsif params[:etablissement_id].present?
                         Etablissement.find(params[:etablissement_id])
                       end
    end

  end
end
