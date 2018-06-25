module MotDePasse

  def normalise_alphanum chaine
    chaine.gsub(/[^[:alnum:]]/, '').upcase
  end

	def normalise date
    return date if date =~ /[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}/
    if date =~ /([[:digit:]]{2})([[:digit:]]{2})([[:digit:]]{4})/
      jour = $1
      mois = $2
    elsif date =~ /([[:digit:]]{1,2})\D+([[:digit:]]{1,2})\D+([[:digit:]]{4})/
      jour = $1.length == 1 ? "0#{$1}" : $1
      mois = $2.length == 1 ? "0#{$2}" : $2
    end
    "#{$3}-#{mois}-#{jour}" if jour
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
