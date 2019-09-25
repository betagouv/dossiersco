# frozen_string_literal: true

class GenerePdf

  def generer_pdf_par_classes(etablissement, pdf_class)
    classes = cherche_classes(etablissement)

    @noms_pdf = []
    parcours_classes(etablissement, classes, pdf_class)

    dossier = "tmp/#{etablissement.id}"
    nom_zip = "convocations.zip"
    temp_file = Tempfile.new(nom_zip)

    construit_zip(temp_file, dossier)
    fichier_a_telecharger = cree_fichier(temp_file, etablissement, pdf_class)
    supprime_temp_file(temp_file, etablissement)
    fichier_a_telecharger
  end

  private

  def cherche_classes(etablissement)
    etablissement.dossier_eleve
                 .includes(%i[eleve resp_legal contact_urgence])
                 .group_by(&:classe_ant)
  end

  def parcours_classes(etablissement, classes, pdf_class)
    classes.each do |classes_dossiers|
      classe_des_eleves = if classes_dossiers[0].present?
                            classes_dossiers[0].gsub(/\s+/, "")
                          else
                            "sans-classe"
                          end
      dossiers_eleve = classes_dossiers[1]
      pdf = pdf_class.constantize.new(etablissement, classe_des_eleves, dossiers_eleve)
      @noms_pdf << pdf.nom
    end
  end

  def construit_zip(temp_file, dossier)
    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
      @noms_pdf.each do |nom_fichier|
        zipfile.add(nom_fichier, File.join(dossier, nom_fichier))
      end
    end
  end

  def supprime_temp_file(temp_file, etablissement)
    temp_file.close
    temp_file.unlink
    FileUtils.rm_rf("tmp/#{etablissement.id}")
  end

  def cree_fichier(temp_file, etablissement, pdf_class)
    FichierATelecharger.create!(contenu: temp_file,
                                etablissement: etablissement,
                                nom: pdf_class)
  end

end
