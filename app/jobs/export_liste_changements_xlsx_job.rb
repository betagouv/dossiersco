# frozen_string_literal: true

class ExportListeChangementsXlsxJob < ActiveJob::Base

  def perform(agent)
    creer_fichier(faire_lignes(agent), cellules_entete(agent), agent)
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

  def cellules_entete(_agent)
    entete = []
    entete << "nom élève"
    entete << "prénom élève"
    entete << "INE"

    2.times do
      entete << "lien de parenté"
      entete << "nom responsable"
      entete << "prénom responsable"
      entete << "nouvelle adresse responsable ligne1"
      entete << "nouvelle adresse responsable ligne2"
      entete << "nouvelle adresse responsable ligne3"
      entete << "nouvelle adresse responsable ligne4"
      entete << "nouveau code postal responsable"
      entete << "nouvelle ville responsable"
      entete << "adresse antérieure responsable"
      entete << "code postal antérieure responsable"
      entete << "ville antérieure responsable"
      entete << "email responsable"
      entete << "tel personnel responsable"
      entete << "tel portable responsable"
      entete << "tel professionnel responsable"
    end

    entete
  end

  def ligne(dossier)
    ligne = []
    ligne << dossier.nom
    ligne << dossier.prenom
    ligne << dossier.identifiant
    dossier.resp_legal.each do |resp|
      ligne << resp.lien_de_parente
      ligne << resp.nom
      ligne << resp.prenom
      ligne << resp.ligne1_adresse_siecle
      ligne << resp.ligne2_adresse_siecle
      ligne << resp.ligne3_adresse_siecle
      ligne << resp.ligne4_adresse_siecle
      ligne << resp.code_postal
      ligne << resp.ville
      ligne << resp.adresse_ant
      ligne << resp.code_postal_ant
      ligne << resp.ville_ant
      ligne << resp.email
      ligne << resp.tel_personnel
      ligne << resp.tel_portable
      ligne << resp.tel_professionnel
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
