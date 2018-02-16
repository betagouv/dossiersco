helpers do
	def construire champs
    	champs.map do |champ|
          erb :'partials/champ', locals: champ
        end
        .join
	end

	def get_eleve redis, identifiant
		ruby_format = redis.hget("dossier_eleve:#{identifiant}",:eleve)
		json_format = ruby_format.gsub(/=>/,':')
		JSON.parse(json_format)
	end
end