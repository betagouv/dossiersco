# frozen_string_literal: true

class ExportElevesXlsxJob < ActiveJob::Base

  def perform(agent)
    lignes = faire_lignes(agent)
    entete = cellules_entete(agent)

    creer_fichier(lignes, entete, agent)

    temp_file = creer_zip(agent)

    FichierATelecharger.create!(contenu: temp_file, etablissement: agent.etablissement, nom: "eleves")

    FileUtils.rm_rf("tmp/eleves-#{agent.etablissement.id}.xlsx")
  end

  def faire_lignes(agent)
    lignes = []
    DossierEleve.where(etablissement: agent.etablissement).each do |dossier|
      options_eleve = cellules_options_eleve(dossier)
      ligne = cellules_infos_base(dossier).concat(options_eleve)
      ligne.concat(cellules_regime_sortie(dossier)) if agent.etablissement.regimes_sortie.count > 1
      ligne << (dossier.autorise_photo_de_classe ? "X" : "")
      ligne << (dossier.renseignements_medicaux ? "X" : "")
      ligne.concat(cellules_pieces_jointes(dossier))
      ligne << dossier.etat
      lignes << ligne
    end
    lignes
  end

  def cellules_entete(agent)
    options_etablissement = agent.etablissement.options_pedagogiques
    entete_options = options_etablissement.map(&:nom)
    entete = ["Classe actuelle", "MEF actuel", "Prenom", "Nom", "Date naissance", "Sexe"].concat(entete_options)

    entete.concat(agent.etablissement.regimes_sortie.map(&:nom)) if agent.etablissement.regimes_sortie.count > 1
    entete.concat(["Autorise photo de classe", "Information médicale"])
    entete.concat(agent.etablissement.pieces_attendues.map(&:nom))
    entete.concat(["Status du dossier"])
    entete
  end

  def cellules_infos_base(dossier)
    mef_origin = dossier.mef_origine.present? ? dossier.mef_origine.libelle : ""
    [dossier.eleve.classe_ant, mef_origin, dossier.eleve.prenom, dossier.eleve.nom,
     dossier.eleve.date_naiss, dossier.eleve.sexe]
  end

  def cellules_options_eleve(dossier)
    options_eleve = []
    dossier.etablissement.options_pedagogiques.each do |option|
      options_eleve << (dossier.options_pedagogiques.include?(option) ? "X" : "")
    end
    options_eleve
  end

  def cellules_regime_sortie(dossier)
    regime_sortie = []
    dossier.etablissement.regimes_sortie.each do |regime|
      regime_sortie << (dossier.regime_sortie == regime ? "X" : "")
    end
    regime_sortie
  end

  def cellules_pieces_jointes(dossier)
    pieces_jointes = []
    dossier.etablissement.pieces_attendues.each do |piece|
      piece_jointe = dossier.pieces_jointes.select { |x| x.piece_attendue_id == piece.id && !x.fichiers.empty? }
      pieces_jointes << (piece_jointe.count.positive? ? "X" : "")
    end
    pieces_jointes
  end

  def creer_fichier(lignes, entete, agent)
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: "Export-eleves") do |sheet|
        sheet.add_row entete
        lignes.each { |ligne| sheet.add_row ligne }
      end
      p.serialize("tmp/eleves-#{agent.etablissement.id}.xlsx")
    end
  end

  def creer_zip(agent)
    dossier = "tmp"
    nom_zip = "eleves.zip"
    nom_fichier = "eleves-#{agent.etablissement.id}.xlsx"
    temp_file = Tempfile.new(nom_zip)

    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
      zipfile.add(nom_fichier, File.join(dossier, nom_fichier))
    end

    temp_file
  end

end
