class GenerePdf

  def generer_par_classe(etablissement)
    classes =  etablissement.dossier_eleve.group_by{ |d| d.eleve.classe_ant }

    noms_pdf = []
    classes.each do |classes_dossiers|
      classe_des_eleves = classes_dossiers[0].present? ? classes_dossiers[0].gsub(/\s+/, "") : ""
      dossiers_eleve = classes_dossiers[1]
      pdf = Pdf.new(etablissement, classe_des_eleves, dossiers_eleve)
      noms_pdf << pdf.nom
    end

    dossier = "#{Rails.root}/tmp/pdf/#{etablissement.nom}"
    nom_zip = "convocations.zip"
    temp_file = Tempfile.new(nom_zip)

    begin
      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
        noms_pdf.each do |nom_fichier|
          zipfile.add(nom_fichier, File.join(dossier, nom_fichier))
        end
      end

      zip_data = File.read(temp_file.path)

    ensure
      temp_file.close
      temp_file.unlink
      FileUtils.rm_rf("#{Rails.root}/tmp/pdf")
    end
    zip_data
  end
end