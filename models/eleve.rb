class Eleve < ActiveRecord::Base
  has_one :dossier_eleve
  has_and_belongs_to_many :option
  has_many :demande
  belongs_to :montee

  def genere_demandes_possibles
    return unless self.montee.present?
    options = self.montee.demandabilite.map { |d| d.option }

    options_par_groupe = options.group_by {|o| o.groupe}
    groupes_obligatoires = []
    groupes_facultatives = []
    options_par_groupe.each do |groupe, options|
      if (groupe.size > 1 && options.first.modalite == 'obligatoire')
        groupes_obligatoires << options
      elsif (options.first.modalite == 'facultative')
        groupes_facultatives << options
      end
    end
    obligatoire(groupes_obligatoires) + facultative(groupes_facultatives)
  end

  def obligatoire options_du_groupe
    options_du_groupe.map do |options|
      {
        label: options.first.groupe,
        name: options.first.groupe,
        type: 'radio',
        options: options.collect(&:nom),
        checked: false
      }
    end
  end

  def facultative options_du_groupe
    options_du_groupe.map do |options|
      options.map do |option|
        {
          name: option.nom,
          label: option.groupe,
          type: "check",
          condition: false,
          desc: option.nom
        }
      end
    end.flatten
  end
end
