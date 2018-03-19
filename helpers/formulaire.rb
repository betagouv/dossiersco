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

	def get_eleve redis, identifiant
		ruby_format = redis.hget("dossier_eleve:#{identifiant}",:eleve)

		if ruby_format.nil?
			session[:erreur_id_ou_date_naiss_incorrecte] = true
			redirect '/'
		end

		json_format = ruby_format.gsub(/=>/,':')
		JSON.parse(json_format)
	end

	def get_demarche redis, identifiant
		redis.hget("dossier_eleve:#{identifiant}", :demarche)
	end

	def get_prenom_eleve redis, identifiant
		eleve = get_eleve(redis, identifiant)
		eleve[:prenom.to_s]
	end

	def get_nom_eleve redis, identifiant
		eleve = get_eleve(redis, identifiant)
		eleve[:nom.to_s]
	end

	def get_date_naiss_eleve redis, identifiant
		eleve = get_eleve(redis, identifiant)
		eleve[:date_naiss.to_s]
	end

	def get_nom_etablissement redis, identifiant
		id_etablissement = redis.hget("dossier_eleve:#{identifiant}", :etablissement)
		etablissement = redis.hgetall("etablissement:#{id_etablissement}")
		etablissement[:nom.to_s]
	end

	def get_localite_etablissement redis, identifiant
		id_etablissement = redis.hget("dossier_eleve:#{identifiant}", :etablissement)
		etablissement = redis.hgetall("etablissement:#{id_etablissement}")
		etablissement[:localite.to_s]
	end

	def get_message_etablissement redis, identifiant
		id_etablissement = redis.hget("dossier_eleve:#{identifiant}", :etablissement)
		etablissement = redis.hgetall("etablissement:#{id_etablissement}")
		etablissement[:message_inscription.to_s]
	end
end