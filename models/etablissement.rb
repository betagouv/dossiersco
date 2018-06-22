class Etablissement < ActiveRecord::Base
  has_many :dossier_eleve
  has_many :agent
  has_many :tache_import
  has_many :piece_attendue

  def classes
    dossier_eleve.collect(&:eleve).collect(&:classe_ant).reject(&:nil?).uniq
  end

  def niveaux
    dossier_eleve.collect(&:eleve).collect(&:niveau_classe_ant).reject(&:nil?).uniq
  end

  def stats
    avec_feedback = []
    etats = []
    DossierEleve
        .where.not(etat: "pas connecté")
        .select { |e| e.etablissement_id == self.id }
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
    dossiers_avec_commentaires = avec_feedback.reject{ |d| d if d.commentaire.nil? || d.commentaire.empty? }
    return etats, notes, moyenne, dossiers_avec_commentaires
  end
end
