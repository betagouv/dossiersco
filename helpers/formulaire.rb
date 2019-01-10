helpers do
	def construire champs
    	champs.map do |champ|
          render partials: 'partials/_champ', locals: champ
        end
        .join
  end



  def get_eleve identifiant
    Eleve.find_by(identifiant: identifiant)
  end
end
