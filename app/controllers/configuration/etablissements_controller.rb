module Configuration
  class EtablissementsController < ApplicationController
    layout 'configuration'

    before_action :if_agent_is_admin, except: [:new, :create]
    before_action :cherche_etablissement, only: [:show, :edit, :update, :destroy]

    def index
      @etablissements = Etablissement.all
    end

    def show
    end

    def new
      @etablissement = Etablissement.new
      render layout: 'connexion'
    end

    def create
      agent = EnregistrementPremierAgentService.new.execute(etablissement_params[:uai])
      if agent
        redirect_to new_configuration_etablissement_path, notice:t('.mail_envoye', mail_ce: agent.email)
      else
        render :new
      end
    end

    def edit
    end

    def update
      @etablissement.update(etablissement_params)
      redirect_to configuration_etablissements_path
    end

    def destroy
      @etablissement.destroy
      redirect_to configuration_etablissements_path, notice: "L'établissement a bien été supprimé"
    end

    def purge
      agent_connecté.etablissement.purge_dossiers_eleves!
      redirect_to new_tache_import_path, notice: t('.purge_succes')
    end

    private

    def etablissement_params
      params.require(:etablissement).permit(:nom, :email, :adresse, :ville, :code_postal, :message_permanence, :message_infirmerie, :gere_demi_pension, :signataire, :date_limite, :uai)
    end

    def cherche_etablissement
      @etablissement = Etablissement.find(params[:id])
    end
  end
end
