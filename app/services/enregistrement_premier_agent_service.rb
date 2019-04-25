# frozen_string_literal: true

class EnregistrementPremierAgentService

  def execute(uai)
    raise StandardError, "uai_invalide" unless uai_valide?(uai)
    raise StandardError, "uai_existant" if Etablissement.exists?(uai: uai.upcase)

    etablissement = Etablissement.create!(uai: uai.upcase)
    jeton = SecureRandom.base58(26)
    email = construit_email_chef_etablissement(uai)
    agent = Agent.create!(etablissement: etablissement, email: email.downcase, jeton: jeton, admin: true)
    AgentMailer.invite_premier_agent(agent).deliver_now
    agent
  end

  def construit_email_chef_etablissement(uai)
    "ce.#{uai}@ac-#{retrouve_academie(uai)}.fr"
  end

  def retrouve_academie(uai)
    departement = uai[0..2]
    ACADEMIES[departement]
  end

  def uai_valide?(uai)
    a_un_format_valide?(uai) &&
      contient_un_departement?(uai) &&
      a_une_clef_de_verification_valide?(uai)
  end

  def a_un_format_valide?(uai)
    uai =~ /^[0-9]{7}[a-zA-Z]$/
  end

  def contient_un_departement?(uai)
    ACADEMIES.key?(uai[0..2])
  end

  def a_une_clef_de_verification_valide?(uai)
    clef = uai.last.downcase
    return false if %w[i q o].include?(clef)

    chiffres = uai[0..6].to_i
    clef == "abcdefghjklmnprstuvwxyz"[chiffres % 23]
  end

  ACADEMIES = JSON.parse(File.read(File.join(Rails.root, "app", "services", "academies.json")))

end
