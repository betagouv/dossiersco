helpers do
	def normalise date
    return date if date =~ /\d{4}-\d\d-\d\d/
    if date =~ /^(\d\d)\/(\d\d)\/(\d{4})/ or date =~ /^(\d\d)\s(\d\d)\s(\d{4})/
      return "#{$3}-#{$2}-#{$1}"
    end
  end

  def message_erreur_identification identifiant, date_naissance
    mois_de_l_année = {
      '01' => 'janvier', '02' => 'février', '03' => 'mars', '04' => 'avril',
      '05' => 'mai', '06' => 'juin', '07' => 'juillet', '08' => 'août',
      '09' => 'septembre', '10' => 'octobre', '11' => 'novembre', '12' => 'décembre'
    }
    annee, mois, jour = normalise(date_naissance).split('-')
    "L'élève a bien comme identifiant #{identifiant} et comme date de naissance le #{jour} #{mois_de_l_année[mois]} #{annee} ?"
  end
end