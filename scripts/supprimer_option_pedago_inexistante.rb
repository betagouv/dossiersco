

dossiers_a_corriger = etablissement.dossier_eleve.select{|d| d.options_origines.keys.include?("321") }
puts dossiers_a_corriger.count
dossiers_a_corriger.each do |dossier|
  options_origines = dossier.options_origines
  if options_origines.keys.include?("503")
    puts "OK DELETE option_origines : #{options_origines}"
    #options_origines.delete("321")
    #dossier.update(options_origines: options_origines)
  end
end


dossiers_a_corriger = etablissement.dossier_eleve.select{|d| d.options_origines.keys.include?("320") }
puts dossiers_a_corriger.count
dossiers_a_corriger.each do |dossier|
  options_origines = dossier.options_origines
  if options_origines.keys.include?("502")
    puts "option_origines : #{options_origines}"
    #options_origines.delete("320")
    #dossier.update(options_origines: options_origines)
  end
end

