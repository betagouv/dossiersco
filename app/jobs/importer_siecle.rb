# frozen_string_literal: true

require "roo"
require "roo-xls"

class ImporterSiecle < ApplicationJob

  queue_as :default

  discard_on(StandardError) do |_job, error|
    ExceptionNotifier.caught(error)
  end

  COLONNES = { sexe: 0, nationalite: 1, prenom: 6, prenom_2: 7, prenom_3: 8, nom: 4, date_naiss: 9, identifiant: 11,
               ville_naiss_etrangere: 20, commune_naiss: 21, pays_naiss: 22, code_mef: 32, niveau_classe_ant: 33, classe_ant: 34,
               nom_resp_legal1: 99, prenom_resp_legal1: 101, date_sortie: 13,
               tel_personnel_resp_legal1: 102, tel_portable_resp_legal1: 104, lien_de_parente_resp_legal1: 103,
               adresse_resp_legal1: 108, ville_resp_legal1: 112, code_postal_resp_legal1: 113, email_resp_legal1: 106,
               nom_resp_legal2: 118, prenom_resp_legal2: 120, tel_personnel_resp_legal2: 121,
               tel_portable_resp_legal2: 123, lien_de_parente_resp_legal2: 122, adresse_resp_legal2: 127,
               ville_resp_legal2: 131, code_postal_resp_legal2: 132, email_resp_legal2: 125 }.freeze

  COLONNES_DES_OPTIONS = [38, 42, 46, 50, 54, 58, 62, 66, 70, 74].freeze

  def perform(tache_id, email)
    tache = TacheImport.find(tache_id)
    tache.update(statut: TacheImport::STATUTS[:en_traitement])

    if tache.import_nomenclature?
      ImportNomenclature.new.perform(tache)
      mail = AgentMailer.succes_import_nomenclature(email)
    else
      statistiques = import_xls(tache)
      mail = AgentMailer.succes_import(email, statistiques)
    end

    mail.deliver_now

    tache.update(statut: TacheImport::STATUTS[:terminee])
  rescue StandardError
    tache.update(statut: TacheImport::STATUTS[:en_erreur])
    AgentMailer.erreur_import(email).deliver_now
  end

  def import_xls(tache)
    import_mef(tache.fichier, tache.etablissement_id)
    import_options(tache.fichier, tache.etablissement_id)
    import_dossiers_eleve(tache.fichier, tache.etablissement_id, tache.type_fichier)
  end

  def import_mef(fichier, etablissement_id)
    xls_document = Roo::Spreadsheet.open fichier
    lignes_siecle = (xls_document.first_row + 1..xls_document.last_row)

    lignes_siecle.each do |row|
      ligne_siecle = xls_document.row(row)
      import_ligne_mef(etablissement_id, ligne_siecle)
    end

    Mef.find_or_create_by(
      etablissement_id: etablissement_id,
      code: "made_in_dossiersco",
      libelle: "CM2"
    )
  end

  def import_ligne_mef(etablissement_id, ligne_siecle)
    return unless ligne_siecle[COLONNES[:code_mef]].present?
    return unless ligne_siecle[COLONNES[:niveau_classe_ant]].present?

    mef = Mef.find_by(
      etablissement_id: etablissement_id,
      libelle: ligne_siecle[COLONNES[:niveau_classe_ant]]
    )

    if mef
      mef.update(code: ligne_siecle[COLONNES[:code_mef]])
      return
    end

    mef = Mef.new(
      etablissement_id: etablissement_id,
      code: ligne_siecle[COLONNES[:code_mef]],
      libelle: ligne_siecle[COLONNES[:niveau_classe_ant]]
    )

    raise mef.errors.full_messages.join(", ") unless mef.save
  end

  def import_options(fichier, etablissement_id)
    xls_document = Roo::Spreadsheet.open fichier
    lignes_siecle = (xls_document.first_row + 1..xls_document.last_row)
    lignes_siecle.each do |row|
      ligne_siecle = xls_document.row(row)
      COLONNES_DES_OPTIONS.each do |colonne|
        next unless ligne_siecle[colonne].present?

        code = ligne_siecle[colonne - 1]
        nom = ligne_siecle[colonne]

        option = OptionPedagogique.find_or_create_by(
          etablissement_id: etablissement_id,
          libelle: nom,
          code_matiere: code
        )
        option.update(nom: nom) if option.nom.nil?
        option.update(obligatoire: true) if ligne_siecle[colonne + 1] == "O"

        if ligne_siecle[COLONNES[:code_mef]].present?
          mef = Mef.find_by(code: ligne_siecle[COLONNES[:code_mef]], etablissement_id: etablissement_id)
          option.mef << mef unless option.mef.include? mef
        end
      end
    end
  end

  def import_dossiers_eleve(fichier, etablissement_id, type)
    xls_document = Roo::Spreadsheet.open fichier
    lignes_siecle = (xls_document.first_row + 1..xls_document.last_row)

    portables = 0
    emails = 0
    nb_eleves_importes = 0
    @eleves_non_importes = []

    lignes_siecle.each do |row|
      ligne_siecle = xls_document.row(row)

      resultat = import_ligne(etablissement_id, ligne_siecle, type)

      portables += 1 if resultat[:portable]
      emails += 1 if resultat[:email]
      nb_eleves_importes += 1 if resultat[:eleve_importe]
    end

    { portable: (portables * 100) / nb_eleves_importes, email: (emails * 100) / nb_eleves_importes,
      eleves: nb_eleves_importes, eleves_non_importes: @eleves_non_importes }
  end

  def import_ligne(etablissement_id, ligne_siecle, type)
    resultat = { portable: false, email: false, eleve_importe: false }
    return resultat if ligne_siecle[COLONNES[:niveau_classe_ant]] =~ /^3.*$/ && type == "reinscription"
    return resultat if ligne_siecle[COLONNES[:niveau_classe_ant]].nil? || !ligne_siecle[COLONNES[:date_sortie]].nil?

    if ligne_siecle[COLONNES[:identifiant]].nil?
      @eleves_non_importes << "#{ligne_siecle[COLONNES[:prenom]]} #{ligne_siecle[COLONNES[:nom]]} (#{ligne_siecle[COLONNES[:date_naiss]]})"
      return resultat
    end

    champs_eleve = %i[sexe nationalite date_naiss prenom prenom_2 prenom_3
                      nom identifiant pays_naiss commune_naiss
                      ville_naiss_etrangere classe_ant niveau_classe_ant]

    donnees_eleve = {}
    champs_eleve.each do |champ|
      valeur = ligne_siecle[COLONNES[champ]]

      if %i[classe_ant niveau_classe_ant].include?(champ) && valeur.present? && type == "inscription"
        mef_courant = Mef.find_by(libelle: valeur, etablissement_id: etablissement_id)
        valeur = Mef.niveau_precedent(mef_courant)&.libelle
      end
      donnees_eleve[champ] = valeur
    end

    donnees_eleve = traiter_donnees_eleve donnees_eleve

    eleve = Eleve.creation_ou_retrouve_par(donnees_eleve[:identifiant])

    return resultat if eleve.id.present? && donnees_eleve[:classe_ant] != eleve.classe_ant

    return resultat if eleve.dossier_eleve&.deja_connecte?

    eleve.update_attributes!(donnees_eleve)

    dossier_eleve = DossierEleve.find_by(eleve_id: eleve.id, etablissement_id: etablissement_id)
    dossier_eleve ||= DossierEleve.new(eleve_id: eleve.id, etablissement_id: etablissement_id)

    if type == "inscription"
      mef_destination = Mef.find_by(
        etablissement_id: etablissement_id,
        code: ligne_siecle[COLONNES[:code_mef]],
        libelle: ligne_siecle[COLONNES[:niveau_classe_ant]]
      )

      mef_origine = Mef.niveau_precedent(mef_destination) if mef_destination.present?
    else
      mef_origine = Mef.find_by(
        etablissement_id: etablissement_id,
        code: ligne_siecle[COLONNES[:code_mef]],
        libelle: ligne_siecle[COLONNES[:niveau_classe_ant]]
      )
      mef_destination = Mef.niveau_superieur(mef_origine) if mef_origine.present?
    end

    dossier_eleve.mef_origine = mef_origine
    dossier_eleve.mef_destination = mef_destination

    unless dossier_eleve.save
      puts dossier_eleve.errors.full_messages.join(", ")
      raise dossier_eleve.errors.full_messages.join(", ")
    end

    COLONNES_DES_OPTIONS.each do |colonne|
      next unless ligne_siecle[colonne].present?

      code = ligne_siecle[colonne - 1]
      nom = ligne_siecle[colonne]

      option = OptionPedagogique.find_or_create_by(
        etablissement_id: etablissement_id,
        nom: nom,
        code_matiere: code
      )

      next if dossier_eleve.options_pedagogiques.include? option

      dossier_eleve.options_pedagogiques << option
      option_origine = {}
      option_origine[:nom] = option.nom
      option_origine[:code_matiere] = option.code_matiere
      option_origine[:groupe] = option.groupe

      dossier_eleve.options_origines[option.id] = option_origine
    end

    dossier_eleve.save!

    champs_resp_legal = %i[nom prenom tel_personnel tel_portable lien_de_parente
                           adresse code_postal ville email]

    donnees_resp_legal = {}
    %w[1 2].each do |i|
      champs_resp_legal.each do |champ|
        donnees_resp_legal[champ] = ligne_siecle[COLONNES["#{champ}_resp_legal#{i}".to_sym]]
      end

      donnees_resp_legal[:dossier_eleve_id] = dossier_eleve.id
      donnees_resp_legal[:priorite] = i.to_i

      donnees_resp_legal[:adresse_ant] = donnees_resp_legal[:adresse]
      donnees_resp_legal[:ville_ant] = donnees_resp_legal[:ville]
      donnees_resp_legal[:code_postal_ant] = donnees_resp_legal[:code_postal]

      resp_legal = RespLegal.find_or_initialize_by(dossier_eleve_id: dossier_eleve.id, priorite: i.to_i)
      resp_legal.update_attributes(donnees_resp_legal)

      resultat[:portable] = true if resp_legal.tel_personnel =~ /^0[67]/ || resp_legal.tel_portable =~ /^0[67]/
      resultat[:email] = true if resp_legal.email =~ /@.*\./
    end

    resultat[:eleve_importe] = true

    resultat
  end

  def traiter_donnees_eleve(donnees_eleve)
    if donnees_eleve[:sexe] == "M"
      donnees_eleve[:sexe] = "Masculin"
    elsif donnees_eleve[:sexe] == "F"
      donnees_eleve[:sexe] = "Féminin"
    end
    donnees_eleve[:date_naiss] = if donnees_eleve[:date_naiss].class == Date
                                   donnees_eleve[:date_naiss].strftime("%Y-%m-%d")
                                 else
                                   donnees_eleve[:date_naiss].split("/").reverse.join("-")
                                 end
    donnees_eleve[:ville_naiss] = if donnees_eleve[:pays_naiss] == "FRANCE"
                                    donnees_eleve[:commune_naiss]
                                  else
                                    donnees_eleve[:ville_naiss_etrangere]
                                  end
    donnees_eleve[:nationalite] = donnees_eleve[:pays_naiss]

    donnees_eleve.delete(:commune_naiss)
    donnees_eleve.delete(:ville_naiss_etrangere)

    donnees_eleve
  end

end
