seed_demo_file = File.join(Rails.root, 'db', 'seed_demo.rb')

namespace :db do

  namespace :seed do
    desc "Charge les données de démo"
    task "demo" => :environment do
      load(seed_demo_file)
    end
  end

  namespace :dump do
    desc "Dump toutes les données de la base courante dans un fichier de chargement de démo"
    task :demo => :environment do
      seedfile = File.open(seed_demo_file, 'w')

      [Etablissement,
       Agent,
       PieceAttendue,
       Mef,
       OptionPedagogique,
       Eleve,
       DossierEleve,
       RespLegal,
       ContactUrgence].each do |klass|
         puts "writing #{klass}"
         seedfile.puts "puts \"loading #{klass}\""
         klass.send(:all).each do |element|
           seedfile.puts "#{klass}.create(#{nettoyer(element)})\n"
         end
       end

       Mef.all.each do |mef|
         unless mef.options_pedagogiques.map(&:id).empty?
           seedfile.puts "puts \"linking mef to options_pedagogiques\""
           seedfile.puts "Mef.find(#{mef.id}).update(options_pedagogiques: #{mef.options_pedagogiques.map(&:id)})"
         end
       end

       seedfile.close
    end

  end
end

def nettoyer(hash)
  hash.attributes.delete_if do |clef, valeur|
    !valeur.present? || clef == 'updated_at' || clef == 'created_at'
  end
end

