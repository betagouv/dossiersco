# frozen_string_literal: true

uai = ARGV[0] 
unless uai.present?
  puts "veuillez fournir l'UAI de l'établissement (exemple : 0770002J)"
  return
end
etablissement = Etablissement.find_by(uai: uai)

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
