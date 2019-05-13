# frozen_string_literal: true

class GenerePdf

  def generer_pdf_par_classes(etablissement, pdf_class)
    classes = etablissement.dossier_eleve
                           .includes(%i[eleve resp_legal contact_urgence])
                           .group_by { |d| d.eleve.classe_ant }

    noms_pdf = []
    classes.each do |classes_dossiers|
      classe_des_eleves = if classes_dossiers[0].present?
                            classes_dossiers[0].gsub(/\s+/, "")
                          else
                            "sans-classe"
                          end
      dossiers_eleve = classes_dossiers[1]
      pdf = pdf_class.constantize.new(etablissement, classe_des_eleves, dossiers_eleve)
      noms_pdf << pdf.nom
    end

    dossier = "tmp/#{etablissement.id}"
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
      FileUtils.rm_rf("tmp/#{etablissement.id}")
    end
    zip_data
  end

end
