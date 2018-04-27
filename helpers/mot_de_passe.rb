helpers do
	def normalise date
    return date if date =~ /\d{4}-\d\d-\d\d/
    if date =~ /^(\d\d)\/(\d\d)\/(\d{4})/ or date =~ /^(\d\d)\s(\d\d)\s(\d{4})/
      return "#{$3}-#{$2}-#{$1}"
    end
  end

  def message_erreur_identification identifiant, date_naissance
    mois_de_l_année = {
      '01' => 'Janvier', '02' => 'Février', '03' => 'Mars', '04' => 'Avril',
      '05' => 'Mai', '06' => 'Juin', '07' => 'Juillet', '08' => 'Août',
      '09' => 'Septembre', '10' => 'Octobre', '11' => 'Novembre', '12' => 'Décembre'
    }
    annee, mois, jour = normalise(date_naissance).split('-')
    "L'élève a bien comme identifiant #{identifiant} et comme date de naissance le #{jour} #{mois_de_l_année[mois]} #{annee} ?"
  end
end