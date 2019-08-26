# frozen_string_literal: true

etablissement = Etablissement.find_by(uai: "0752550P")

dossiers = etablissement.dossier_eleve

dossiers.each do |dossier|
  puts "dossier.options_origines : #{dossier.options_origines}"
  dossier.options_origines.keys.each do |option_id|
    puts "key : #{option_id}"
    option = OptionPedagogique.find(option_id)

    option_origine = {}
    option_origine[:nom] = option.nom
    option_origine[:code_matiere] = option.code_matiere
    option_origine[:groupe] = option.groupe

    puts option_origine
    dossier.options_origines[option.id] = option_origine
  end
  dossier.save!
end
