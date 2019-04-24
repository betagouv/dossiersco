require 'roo'
require 'roo-xls'

class ImporterSiecle < ApplicationJob
  queue_as :default

  discard_on(StandardError) do |job, error|
    ExceptionNotifier.caught(error)
  end

  COLONNES = {sexe: 0, nationalite: 1, prenom: 6, prenom_2: 7, prenom_3: 8, nom: 4, date_naiss: 9, identifiant: 11,
              ville_naiss_etrangere: 20, commune_naiss: 21, pays_naiss: 22, code_mef: 32, niveau_classe_ant: 33, classe_ant: 34,
              nom_resp_legal1: 99, prenom_resp_legal1: 101, date_sortie: 13,
              tel_personnel_resp_legal1: 102, tel_portable_resp_legal1: 104, tel_professionnel_resp_legal1: 105, lien_de_parente_resp_legal1: 103,
              adresse_resp_legal1: 108, ville_resp_legal1: 112, code_postal_resp_legal1: 113, email_resp_legal1: 106,
              nom_resp_legal2: 118, prenom_resp_legal2: 120, tel_personnel_resp_legal2: 121,
              tel_portable_resp_legal2: 123, tel_professionnel_resp_legal2: 124, lien_de_parente_resp_legal2: 122, adresse_resp_legal2: 127,
              ville_resp_legal2: 131, code_postal_resp_legal2: 132, email_resp_legal2: 125}

  def perform(tache_id, email)
    tache = TacheImport.find(tache_id)
    begin
      tache.update(statut: TacheImport::STATUTS[:en_traitement])
      statistiques = import_xls tache.fichier.path, tache.etablissement_id
      mail = AgentMailer.succes_import(email, statistiques)
      tache.update(statut: TacheImport::STATUTS[:terminee])
      mail.deliver_now
    rescue
      tache.update(statut: TacheImport::STATUTS[:en_erreur])
      AgentMailer.erreur_import(email).deliver_now
    end
  end

  def import_xls fichier, etablissement_id
    import_mef(fichier, etablissement_id)
    import_dossiers_eleve(fichier, etablissement_id)
  end

  def import_dossiers_eleve(fichier, etablissement_id)
    xls_document = Roo::Spreadsheet.open fichier
    lignes_siecle = (xls_document.first_row + 1..xls_document.last_row)

    portables = 0
    emails = 0
    nb_eleves_importes = 0
    @eleves_non_importes = []

    lignes_siecle.each do |row|
      ligne_siecle = xls_document.row(row)

      resultat = import_ligne(etablissement_id, ligne_siecle)

      portables += 1 if resultat[:portable]
      emails += 1 if resultat[:email]
      nb_eleves_importes += 1 if resultat[:eleve_importe]
    end

    {portable: (portables * 100) / nb_eleves_importes, email: (emails * 100) / nb_eleves_importes,
     eleves: nb_eleves_importes, eleves_non_importes: @eleves_non_importes}
  end

  def import_mef(fichier, etablissement_id)
    xls_document = Roo::Spreadsheet.open fichier
    lignes_siecle = (xls_document.first_row + 1..xls_document.last_row)

    lignes_siecle.each do |row|
      ligne_siecle = xls_document.row(row)
      import_ligne_mef(etablissement_id, ligne_siecle)
    end
  end

  def import_ligne_mef(etablissement_id, ligne_siecle)
    return unless ligne_siecle[COLONNES[:code_mef]].present?
    return unless ligne_siecle[COLONNES[:niveau_classe_ant]].present?
    mef = Mef.find_by(etablissement_id: etablissement_id, code: ligne_siecle[COLONNES[:code_mef]], libelle: ligne_siecle[COLONNES[:niveau_classe_ant]])
    mef ||= Mef.new(etablissement_id: etablissement_id, code: ligne_siecle[COLONNES[:code_mef]], libelle: ligne_siecle[COLONNES[:niveau_classe_ant]])
    unless mef.save
      puts mef.errors.full_messages.join(', ')
      raise mef.errors.full_messages.join(', ')
    end
  end

  def import_ligne_adresse etablissement_id, ligne_siecle
    eleve = Eleve.find_by(identifiant: ligne_siecle[COLONNES[:identifiant]])
    return unless eleve.present?

    champs_resp_legal = [:code_postal, :ville]

    ['1', '2'].each do |i|
      donnees_resp_legal = {}
      champs_resp_legal.each do |champ|
        donnees_resp_legal[champ] = ligne_siecle[COLONNES["#{champ}_resp_legal#{i}".to_sym]]
      end

      resp_legal = RespLegal.find_by(priorite: i.to_i, dossier_eleve_id: eleve.dossier_eleve.id)
      resp_legal.update(
        ville_ant: donnees_resp_legal[:ville],
        adresse_ant: (concatener_adresse ligne_siecle, resp_legal.priorite),
        code_postal_ant: donnees_resp_legal[:code_postal])
    end
  end

  def concatener_adresse ligne_siecle, priorite
    colonnes_adresse = { 'resp_legal1' => [108, 109, 110, 111], 'resp_legal2' => [127, 128, 129, 130]}
    adresse = ""
    colonnes_adresse["resp_legal#{priorite}"].each do |colonne|
      adresse << "#{ligne_siecle[colonne]} \n " unless ligne_siecle[colonne].nil?
    end
    adresse
  end

  def import_ligne(etablissement_id, ligne_siecle)
    resultat = {portable: false, email: false, eleve_importe: false}
    return resultat if ligne_siecle[COLONNES[:niveau_classe_ant]] =~ /^3.*$/
    return resultat if ligne_siecle[COLONNES[:niveau_classe_ant]].nil? || !ligne_siecle[COLONNES[:date_sortie]].nil?
    if ligne_siecle[COLONNES[:identifiant]].nil?
      @eleves_non_importes << "#{ligne_siecle[COLONNES[:prenom]]} #{ligne_siecle[COLONNES[:nom]]} (#{ligne_siecle[COLONNES[:date_naiss]]})"
      return resultat
    end

    champs_eleve = [:sexe,:nationalite, :date_naiss, :prenom, :prenom_2, :prenom_3, :nom,
                    :identifiant, :pays_naiss, :commune_naiss, :ville_naiss_etrangere, :classe_ant,
                    :niveau_classe_ant]

    donnees_eleve = {}
    champs_eleve.each do |champ|
      donnees_eleve[champ] = ligne_siecle[COLONNES[champ]]
    end

    donnees_eleve = traiter_donnees_eleve donnees_eleve

    eleve = Eleve.creation_ou_retrouve_par(donnees_eleve[:identifiant])

    return resultat if eleve.id.present? && donnees_eleve[:classe_ant] != eleve.classe_ant

    eleve.update_attributes!(donnees_eleve)

    mef_origine = Mef.find_by(code: ligne_siecle[COLONNES[:code_mef]], libelle: ligne_siecle[COLONNES[:niveau_classe_ant]])
    mef_destination = Mef.niveau_superieur(mef_origine) if mef_origine.present?

    dossier_eleve = DossierEleve.find_by(eleve_id: eleve.id, etablissement_id: etablissement_id)
    dossier_eleve ||= DossierEleve.new(eleve_id: eleve.id, etablissement_id: etablissement_id)
    dossier_eleve.mef_origine = mef_origine
    dossier_eleve.mef_destination = mef_destination

    unless dossier_eleve.save
      puts dossier_eleve.errors.full_messages.join(', ')
      raise dossier_eleve.errors.full_messages.join(', ')
    end

    [38,42,46,50,54,58,62,66,70,74].each do |colonne|
      next unless ligne_siecle[colonne].present?

      option = OptionPedagogique.find_or_create_by(etablissement_id: etablissement_id, nom: ligne_siecle[colonne])
      option.update(obligatoire: true) if ligne_siecle[colonne + 1] == 'O'

      if ligne_siecle[COLONNES[:code_mef]].present?
        mef = Mef.find_by(code: ligne_siecle[COLONNES[:code_mef]], etablissement_id: etablissement_id)
        unless option.mef.include? mef
          option.mef << mef
        end
      end

      dossier_eleve.options_pedagogiques << option
      option_origine = {}
      option_origine[:nom] = option.nom
      option_origine[:groupe] = option.groupe

      dossier_eleve.options_origines[option.id] = option_origine
      dossier_eleve.save!
    end

    champs_resp_legal = [:nom, :prenom, :tel_personnel, :tel_portable, :tel_professionnel, :lien_de_parente,
                         :adresse, :code_postal, :ville, :email]

    donnees_resp_legal = {}
    ['1', '2'].each do |i|
      champs_resp_legal.each do |champ|
        donnees_resp_legal[champ] = ligne_siecle[COLONNES["#{champ}_resp_legal#{i}".to_sym]]
      end

      donnees_resp_legal[:dossier_eleve_id] = dossier_eleve.id
      donnees_resp_legal[:priorite] = i.to_i

      donnees_resp_legal[:adresse_ant] = donnees_resp_legal[:adresse]
      donnees_resp_legal[:ville_ant] = donnees_resp_legal[:ville]
      donnees_resp_legal[:code_postal_ant] = donnees_resp_legal[:code_postal]

      resp_legal = RespLegal.find_or_initialize_by(dossier_eleve_id: dossier_eleve.id, priorite: i.to_i)
      resp_legal.update_attributes!(donnees_resp_legal)

      resultat[:portable] = true if resp_legal.tel_personnel =~ /^0[67]/ or resp_legal.tel_portable =~ /^0[67]/
      resultat[:email] = true if resp_legal.email =~ /@.*\./
    end

    resultat[:eleve_importe] = true

    return resultat
  end

  def traiter_donnees_eleve donnees_eleve
    if donnees_eleve[:sexe] == 'M'
      donnees_eleve[:sexe] = 'Masculin'
    elsif donnees_eleve[:sexe] == 'F'
      donnees_eleve[:sexe] = 'Féminin'
    end
    if donnees_eleve[:date_naiss].class == Date
      donnees_eleve[:date_naiss] = donnees_eleve[:date_naiss].strftime('%Y-%m-%d')
    else
      donnees_eleve[:date_naiss] = donnees_eleve[:date_naiss].split('/').reverse.join('-')
    end
    if donnees_eleve[:pays_naiss] == 'FRANCE'
      donnees_eleve[:ville_naiss] = donnees_eleve[:commune_naiss]
    else
      donnees_eleve[:ville_naiss] = donnees_eleve[:ville_naiss_etrangere]
    end
    donnees_eleve[:nationalite] = donnees_eleve[:pays_naiss]

    donnees_eleve.delete(:commune_naiss)
    donnees_eleve.delete(:ville_naiss_etrangere)

    return donnees_eleve
  end
end
