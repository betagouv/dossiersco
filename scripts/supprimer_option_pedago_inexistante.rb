# frozen_string_literal: true

dossiers_a_corriger = etablissement.dossier_eleve.select { |d| d.options_origines.key?("321") }
puts dossiers_a_corriger.count
dossiers_a_corriger.each do |dossier|
  options_origines = dossier.options_origines
  next unless options_origines.key?("503")

  puts "OK DELETE option_origines : #{options_origines}"
  # options_origines.delete("321")
  # dossier.update(options_origines: options_origines)
end

dossiers_a_corriger = etablissement.dossier_eleve.select { |d| d.options_origines.key?("320") }
puts dossiers_a_corriger.count
dossiers_a_corriger.each do |dossier|
  options_origines = dossier.options_origines
  next unless options_origines.key?("502")

  puts "option_origines : #{options_origines}"
  # options_origines.delete("320")
  # dossier.update(options_origines: options_origines)
end
