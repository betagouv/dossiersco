class EnregistrementPremierAgentService
	def execute(uai)
		etablissement = Etablissement.create!(uai: uai)
		jeton = SecureRandom.base58(26)
		email = construit_email_chef_etablissement(uai)
		agent = Agent.create!(etablissement: etablissement, identifiant: email, email: email, jeton: jeton, admin: true)
		AgentMailer.invite_premier_agent(agent).deliver_now
		agent
	end

	def construit_email_chef_etablissement(uai)
		"ce.#{uai}@ac-paris.fr"
	end
end