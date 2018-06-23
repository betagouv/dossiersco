require_relative 'import_siecle'

module AgentHelpers
  def agent
    Agent.find_by(identifiant: session[:identifiant])
  end

  def traiter_imports
    tache = TacheImport.find_by(statut: 'en_attente')
    return unless tache
    tache.traiter
  end

  def traiter_messages
    message = Message.find_by(etat: 'en_attente')
    return unless message
    message.envoyer
  end
end

Sinatra::Application.helpers AgentHelpers
