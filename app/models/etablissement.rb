class Etablissement < ActiveRecord::Base
  has_many :dossier_eleve, dependent: :destroy
  has_many :agent, dependent: :destroy
  has_many :tache_import, dependent: :destroy
  has_many :piece_attendue, dependent: :destroy
  has_many :modele, dependent: :destroy

  validates :code_postal, length: { is: 5 }, numericality: { only_integer: true }, allow_nil: true
  validates :uai, presence: true

  def classes
    dossier_eleve.collect(&:eleve).collect(&:classe_ant).reject(&:nil?).uniq
  end

  def niveaux
    dossier_eleve.collect(&:eleve).collect(&:niveau_classe_ant).reject(&:nil?).uniq
  end

  def stats
    avec_feedback = []
    etats = {}
    DossierEleve
        .where.not(etat: "pas connecté")
        .select { |e| e.etablissement_id == self.id }
        .group_by(&:etat)
        .each_pair do |etat, dossiers_etat|
            etats[etat] = dossiers_etat.count
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

  def departement
    code_postal.present? ? code_postal[0..1] : ''
  end
end
