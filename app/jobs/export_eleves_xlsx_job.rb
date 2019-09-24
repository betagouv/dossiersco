# frozen_string_literal: true

class ExportElevesXlsxJob < ActiveJob::Base

  def perform(agent)
    creer_fichier(faire_lignes(agent), cellules_entete(agent), agent)
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
      ligne << (dossier.demi_pensionnaire? ? "X" : "")
      ligne.concat(cellules_responsable_legaux(dossier))
      lignes << ligne
    end
    lignes
  end

  def cellules_entete(agent)
    entete = []
    entete << "Classe actuelle"
    entete << "MEF actuel"
    entete << "Prenom"
    entete << "Nom"
    entete << "Date naissance"
    entete << "Pays naissance"
    entete << "Ville naissance"
    entete << "Commune INSEE naissance"
    entete << "Nationalite"
    entete << "Sexe"
    entete.concat(agent.etablissement.options_pedagogiques.map(&:nom))
    entete.concat(agent.etablissement.regimes_sortie.map(&:nom)) if agent.etablissement.regimes_sortie.count > 1
    entete.concat(["Autorise photo de classe", "Information médicale"])
    entete.concat(agent.etablissement.pieces_attendues.map(&:nom))
    entete << "Status du dossier"
    entete << "Demi-pensionnaire"

    2.times do
      entete << "lien_de_parente"
      entete << "prenom"
      entete << "nom"
      entete << "adresse"
      entete << "code_postal"
      entete << "ville"
      entete << "pays"
      entete << "ville_etrangere"
      entete << "tel_personnel"
      entete << "tel_portable"
      entete << "tel_professionnel"
      entete << "email"
      entete << "profession"
      entete << "enfants_a_charge"
      entete << "communique_info_parents_eleves"
      entete << "paie_frais_scolaires"
    end

    entete
  end

  def cellules_infos_base(dossier)
    pays = Pays.new
    nationalite = Nationalite.new
    eleve = dossier.eleve
    informations = []
    informations << eleve.classe_ant
    informations << (dossier.mef_origine.present? ? dossier.mef_origine.libelle : "")
    informations << dossier.prenom
    informations << dossier.nom
    informations << eleve.date_naiss
    informations << pays.a_partir_du_code(dossier.pays_naiss)
    informations << dossier.ville_naiss
    informations << dossier.commune_insee_naissance
    informations << nationalite.a_partir_du_code(eleve.nationalite)
    informations << eleve.sexe
    informations
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
    nom_fichier = "eleves-#{agent.etablissement.id}.xlsx"
    temp_file = Tempfile.new("eleves.zip")
    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
      zipfile.add(nom_fichier, File.join("tmp", nom_fichier))
    end
    temp_file
  end

  def cellules_responsable_legaux(dossier)
    responsables = []
    dossier.resp_legal.each do |responsable|
      responsables << responsable.lien_de_parente
      responsables << responsable.prenom
      responsables << responsable.nom
      responsables << responsable.adresse
      responsables << responsable.code_postal
      responsables << responsable.ville
      responsables << responsable.pays
      responsables << responsable.ville_etrangere
      responsables << responsable.tel_personnel
      responsables << responsable.tel_portable
      responsables << responsable.tel_professionnel
      responsables << responsable.email
      responsables << responsable.profession
      responsables << responsable.enfants_a_charge
      responsables << responsable.communique_info_parents_eleves
      responsables << responsable.paie_frais_scolaires
    end
    responsables
  end

end
