module AgentHelpers
  def agent
    Agent.find_by(identifiant: session[:identifiant])
  end
  def traiter_imports
    tache = TacheImport.find_by(statut: 'en_attente')
    return unless tache
    tache.update(statut: 'en_cours')
    import_xls tache.url, tache.etablissement_id, nom_a_importer=nil, prenom_a_importer=nil
    tache.update(statut: 'terminée')
  end
end

Sinatra::Application.helpers AgentHelpers
