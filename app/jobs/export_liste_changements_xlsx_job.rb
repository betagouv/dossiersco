# frozen_string_literal: true

class ExportListeChangementsXlsxJob < ActiveJob::Base

  def perform(agent)
    creer_fichier(faire_lignes(agent), cellules_entete, agent)
    temp_file = creer_zip(agent)
    FichierATelecharger.create!(contenu: temp_file, etablissement: agent.etablissement, nom: "changements")
    FileUtils.rm_rf("tmp/changements-#{agent.etablissement.id}.xlsx")
  end

  def faire_lignes(agent)
    lignes = []
    DossierEleve.where(etablissement: agent.etablissement).each do |dossier|
      lignes << ligne(dossier) if dossier.resp_legal.map(&:adresse_inchangee?).uniq.include?(false)
    end
    lignes
  end

  def cellules_entete
    ["nom élève", "prénom élève", "INE", "MEF destination"].concat(entetes_responsables)
  end

  def entetes_responsables
    [
      "lien de parenté", "nom responsable", "prénom responsable", "nouvelle adresse responsable ligne1",
      "nouvelle adresse responsable ligne2", "nouvelle adresse responsable ligne3", "nouvelle adresse responsable ligne4",
      "nouveau code postal responsable", "nouvelle ville responsable", "adresse antérieure responsable", "code postal antérieure responsable",
      "ville antérieure responsable", "email responsable", "tel personnel responsable", "tel portable responsable", "tel professionnel responsable"
    ] * 2
  end

  def ligne(dossier)
    ligne = [dossier.nom, dossier.prenom, dossier.identifiant, dossier.mef_destination.libelle]
    dossier.resp_legal.each do |resp|
      ligne.concat [
        resp.lien_de_parente, resp.nom, resp.prenom,
        resp.ligne1_adresse_siecle, resp.ligne2_adresse_siecle, resp.ligne3_adresse_siecle, resp.ligne4_adresse_siecle,
        resp.code_postal, resp.ville, resp.adresse_ant, resp.code_postal_ant, resp.ville_ant, resp.email,
        resp.tel_personnel, resp.tel_portable, resp.tel_professionnel
      ]
    end

    ligne
  end

  def creer_fichier(lignes, entete, agent)
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: "Export-Changements") do |sheet|
        sheet.add_row entete
        lignes.each { |ligne| sheet.add_row ligne }
      end
      p.serialize("tmp/changements-#{agent.etablissement.id}.xlsx")
    end
  end

  def creer_zip(agent)
    nom_fichier = "changements-#{agent.etablissement.id}.xlsx"
    temp_file = Tempfile.new("changements.zip")
    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
      zipfile.add(nom_fichier, File.join("tmp", nom_fichier))
    end
    temp_file
  end

end
