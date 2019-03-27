module Configuration
  class AgentsController < ApplicationController
    layout 'configuration'

    before_action :identification_agent
    before_action :if_agent_is_admin, except: [:edit, :update, :activation]

    def new
      @agent = Agent.new
    end

    def create
      @agent = Agent.new(agent_params)
      @agent.email.downcase!
      @agent.etablissement = @agent_connecté.etablissement
      @agent.jeton = SecureRandom.base58(26)
      if @agent.save
        AgentMailer.invite_agent(@agent, @agent_connecté).deliver_now
        redirect_to configuration_agents_path, notice: t('.invitation_envoyee', email: @agent.email)
      else
        flash[:alert] = "L'email #{@agent.email} est déjà utilisé"
        render :new
      end
    end

    def index
      super_admins = ENV['SUPER_ADMIN'].present? ? ENV['SUPER_ADMIN'].gsub(' ', "").split(",") : ['']
      @agents = Agent.where(etablissement: agent_connecté.etablissement).where.not("email IN (?)", super_admins)
    end

    def edit
      @agent = @agent_connecté
    end

    def update
      ancien_jeton = @agent_connecté.jeton
      @agent_connecté.jeton = nil
      if @agent_connecté.update(agent_params)
        session[:agent_email] = @agent_connecté.email
        redirect_to configuration_agents_path, notice: t('messages.compte_cree')
      else
        @agent = @agent_connecté
        @agent.jeton = ancien_jeton
        if @agent_connecté.jeton
          render :activation, layout: 'connexion'
        else
          render :edit
        end
      end
    end

    def destroy
      @agent = Agent.find(params[:id])
      @agent.destroy
      redirect_to configuration_agents_path, notice: "L'agent a bien été supprimé"
    end

    def changer_etablissement
      @agent_connecté.update(etablissement_id: params[:etablissement])
      redirect_to agent_tableau_de_bord_path
    end

    def activation
      @agent = @agent_connecté
      render layout: 'connexion'
    end

    private
    def agent_params
      params.require(:agent).permit(:prenom, :nom, :password, :etablissement_id, :admin, :email)
    end

  end
end
