helpers do
	def construire champs
    	champs.map do |champ|
          erb :'partials/champ', locals: champ
        end
        .join
	end
end


