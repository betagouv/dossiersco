helpers do
	def construire champs
    	champs.map do |champ|
          erb :'partials/champ', locals: champ
        end
        .join
  end



  def get_eleve identifiant
    Eleve.find_by(identifiant: identifiant)
  end
end
