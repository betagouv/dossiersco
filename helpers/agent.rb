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

  def stats etablissement
    avec_feedback = []
    etats = []
    DossierEleve
        .where.not(etat: "pas connecté")
        .select { |e| e.etablissement_id == etablissement.id }
        .group_by(&:etat)
        .each_pair do |etat, dossiers_etat|
            etats.push("#{etat}:#{dossiers_etat.count}")
            if (etat.include? "valid")
                avec_feedback.push(*dossiers_etat)
            end
        end
    notes = avec_feedback.collect(&:satisfaction)
    notes_renseignees = notes.select {|n| n > 0}
    moyenne = notes_renseignees.count > 0 ? "#{'%.2f' % ((notes_renseignees.sum+0.0)/notes_renseignees.count)}" : ""
    commentaires = avec_feedback.collect(&:commentaire).reject(&:nil?).reject(&:empty?)
    return etats, notes, moyenne, commentaires
  end
end

Sinatra::Application.helpers AgentHelpers
