# frozen_string_literal: true

module Configuration
  class EtablissementsController < ApplicationController

    layout "configuration"

    before_action :if_agent_is_admin, except: %i[new create]
    before_action :cherche_etablissement, only: %i[show edit update]

    def show; end

    def new
      render layout: "connexion"
    end

    def create
      agent = EnregistrementPremierAgentService.new.execute(etablissement_params[:uai])
      PrerempliEtablissement.perform_later(agent.etablissement.uai)
      redirect_to new_configuration_etablissement_path, notice: t(".mail_envoye", mail_ce: agent.email)
    rescue StandardError => error
      flash[:error] = t(".#{error}")
      render :new, layout: "connexion"
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

    private

    def etablissement_params
      params.require(:etablissement).permit(:nom, :email, :adresse, :ville, :code_postal,
                                            :gere_demi_pension, :signataire, :date_limite, :uai,
                                            :envoyer_aux_familles, :reglement_demi_pension, :mot_accueil)
    end

    def cherche_etablissement
      @etablissement = Etablissement.find(params[:id])
    end

  end
end
