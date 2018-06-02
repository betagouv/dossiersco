require_relative 'import_siecle'

module AgentHelpers
  def agent
    p "session:#{session.inspect}"
    Agent.find_by(identifiant: session[:identifiant])
  end
  def traiter_imports
    tache = TacheImport.find_by(statut: 'en_attente')
    return unless tache
    tache.update(statut: 'en_cours')
    statistiques = import_xls tache.url, tache.etablissement_id, tache.nom_a_importer, tache.prenom_a_importer
    tache.update(
      statut: 'terminée',
      message: "#{statistiques[:eleves]} élèves importés : "+
      "#{statistiques[:portable]}% de téléphones portables et "+
      "#{statistiques[:email]}% d'emails")
  end
end

Sinatra::Application.helpers AgentHelpers
