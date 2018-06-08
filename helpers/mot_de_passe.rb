module MotDePasse
	def normalise date
    return date if date =~ /\d{4}-\d\d-\d\d/
    if date =~ /([\d]{1,2})[^\d]+([\d]{1,2})[^\d]+([\d]{4})/
      jour = $1.length == 1 ? "0#{$1}" : $1
      mois = $2.length == 1 ? "0#{$2}" : $2
      return "#{$3}-#{mois}-#{jour}"
    end
  end

  def message_erreur_identification identifiant, date_naissance
    mois_de_l_année = {
      '01' => 'janvier', '02' => 'février', '03' => 'mars', '04' => 'avril',
      '05' => 'mai', '06' => 'juin', '07' => 'juillet', '08' => 'août',
      '09' => 'septembre', '10' => 'octobre', '11' => 'novembre', '12' => 'décembre'
    }
    if identifiant.to_s.empty? || date_naissance.to_s.empty?
      return "Veuillez fournir identifiant et date de naissance"
    end
    annee, mois, jour = normalise(date_naissance).split('-')
    "L'élève a bien comme identifiant #{identifiant} et comme date de naissance le #{jour} #{mois_de_l_année[mois]} #{annee} ?"
  end
end

Sinatra::Application.helpers MotDePasse
