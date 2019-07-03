# frozen_string_literal: true

class ExportPiecesJointesJob < ActiveJob::Base

  def perform(agent, mef_id)
    nom_zip = "pieces-jointes.zip"
    temp_file = Tempfile.new(nom_zip)

    mef_selectionnes = if mef_id.blank?
                         Mef.where(etablissement: agent.etablissement)
                       else
                         Mef.where(id: mef_id)
                       end

    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
      mef_selectionnes.each do |mef|
        DossierEleve.where(mef_origine: mef).each do |dossier_eleve|
          eleve = dossier_eleve.eleve
          next if eleve.identifiant.nil? || dossier_eleve.pieces_jointes.empty?

          dossier_eleve.pieces_jointes.each do |piece|
            piece.fichiers.each_with_index do |fichier, index|
              format = fichier.file.file.split(".").last
              eleve_folder = "#{eleve.prenom}-#{eleve.nom}-#{eleve.identifiant}"
              begin
                zipfile.add(
                    "#{mef.libelle}/#{eleve_folder}/#{fichier.model.piece_attendue.nom}-#{index}.#{format}",
                    File.join(fichier.file.file)
                )
              rescue
                next
              end
            end
          end
        end
      end
    end

    FichierATelecharger.create!(contenu: temp_file, etablissement: agent.etablissement, nom: "pieces-jointes")
  end

end
