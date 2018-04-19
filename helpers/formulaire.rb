helpers do
	def construire champs
    	champs.map do |champ|
          erb :'partials/champ', locals: champ
        end
        .join
  end

  def get_dossier_eleve identifiant
    DossierEleve.joins(:eleve).find_by(eleves: {identifiant: identifiant})
  end

  def get_eleve identifiant
    Eleve.find_by(identifiant: identifiant)
  end

  def options_eligibles_classees eleve, etablissement_id
    options = options_eligibles eleve, etablissement_id
    {
      obligatoire: options.select { |option| option.obligatoire },
      facultative: options.select { |option| !option.obligatoire }
    }
  end

  def options_eligibles eleve, etablissement_id
    if eleve.niveau_classe_ant.nil?
      niveau_debut = 6
    else
      niveau_debut = eleve.niveau_classe_ant[0].to_i - 1
    end

    Option.where etablissement_id: etablissement_id, niveau_debut: niveau_debut
  end
end