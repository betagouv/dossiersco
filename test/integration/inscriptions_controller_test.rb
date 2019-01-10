require 'test_helper'
require 'fixtures'
require 'import_siecle'
init

class InscriptionsControllerTest < ActionDispatch::IntegrationTest

  def test_entree_succes_agent
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    follow_redirect!
    assert response.body.include? 'Collège Germaine Tillion'
  end

  def test_entree_mauvais_mdp_agent
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'pierre'}
    follow_redirect!
    assert response.body.include? 'Ces informations ne correspondent pas à un agent enregistré'
  end

  def test_entree_mauvais_identifiant_agent
    post '/agent', params: {identifiant: 'jacques', mot_de_passe: 'pierre'}
    follow_redirect!
    assert response.body.include? 'Ces informations ne correspondent pas à un agent enregistré'
  end

  def test_nombre_dossiers_total
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    follow_redirect!
    doc = Nokogiri::HTML(response.body)
    selector = '#total_dossiers'
    affichage_total_dossiers = doc.css(selector).text
    assert_equal '5', affichage_total_dossiers
  end

  def test_importe_eleve_fichier_siecle
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    import_siecle_xls = fixture_file_upload('files/test_import_siecle.xls','application/vnd.ms-excel')
    post '/agent/import_siecle', params: {nom_eleve: "", prenom_eleve: "", name: 'import_siecle',
         filename: import_siecle_xls}

    doc = Nokogiri::HTML(response.body)
    assert_match "L'import de cette base sera réalisé prochainement.", doc.css('.statut-import').text

    tache_import = TacheImport.find_by(statut: 'en_attente')
    assert tache_import != nil
    # assert_equal('tests/test_import_siecle.xls', tache_import.url)
  end

  def test_affiche_statut_import
    agent = Agent.find_by(identifiant: 'pierre')
    tache_import = TacheImport.create(
        url: 'tests/test_import_siecle.xls',
        statut: 'en_cours',
        etablissement_id: agent.etablissement.id)
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}

    get '/agent/import_siecle'
    doc = Nokogiri::HTML(response.body)
    assert_match "L'import de cette base est en cours.", doc.css('.statut-import').text
    assert_empty doc.css("button[type=submit]")
  end

  def test_traiter_zero_imports
    get '/api/traiter_imports'
    assert_equal 200, response.status
  end

  def test_traiter_import_eleve_fichier_siecle
    nombre_eleves_debut = Eleve.all.count
    etablissement = Etablissement.find_by(nom: 'Collège Germaine Tillion')
    tache_import = TacheImport.create(url: 'test/fixtures/files/test_import_siecle.xls', statut: 'en_attente',
      etablissement_id: etablissement.id)
    get '/api/traiter_imports'
    assert_equal 200, response.status

    eleve = Eleve.find_by(nom: 'NOM_TEST')
    eleve2 = Eleve.find_by(nom: 'NOM2_TEST')
    nombre_eleves_importes = Eleve.all.count - nombre_eleves_debut

    assert_equal 2, nombre_eleves_importes
    assert_equal 'Masculin', eleve.sexe
    assert_equal 'Prenom_test', eleve.prenom
    assert_equal 'Prenom_test_2', eleve.prenom_2
    assert_equal 'Prenom_test_3', eleve.prenom_3
    assert_equal '080788316HE', eleve.identifiant
    assert_equal 'FRANCE', eleve.pays_naiss
    assert_equal 'PARIS 12E  ARRONDISSEMENT', eleve.ville_naiss
    assert_equal '4A', eleve.classe_ant
    assert_equal 'Collège Germaine Tillion', eleve.dossier_eleve.etablissement.nom
    assert_equal 'Prenom2_test', eleve2.prenom
    assert_equal '080788306HE', eleve2.identifiant
    assert_equal 'CONGO', eleve2.pays_naiss
    assert_equal 'Brazaville', eleve2.ville_naiss
    assert_equal '4EME HORAIRES AMENAGES MUSIQUE', eleve2.niveau_classe_ant

    tache_import = TacheImport.find_by(statut: 'terminée')
    assert_equal(tache_import.url, 'test/fixtures/files/test_import_siecle.xls')
  end

  def test_import_des_options
    Option.destroy_all
    etablissement = Etablissement.find_by(nom: 'College Jean-Francois Oeben')
    lignes_siecle = [
      {11 => '1', 9 => "18/05/1991", 37 => "AGL1", 38 => "ANGLAIS LV1", 39 => "O", 33 => '4', 34 => '4EME 1'},
      {11 => '2', 9 => "18/05/1991", 37 => "ESP2", 38 => "ESPAGNOL LV2", 39 => "F", 33 => '4', 34 => '6EME 1'},
      {11 => '3', 9 => "18/05/1991", 37 => "AGL1", 38 => "ANGLAIS LV1", 39 => "O", 33 => '4', 34 => '3EME 1'},
      {11 => '4', 9 => "18/05/1991", 41 => "DANSE", 42 => "DANSE", 43 => "F", 33 => '4', 34 => '4EME 1'}
    ]

    lignes_siecle.each { |ligne| import_ligne etablissement.id, ligne }

    options = Option.all

    assert_equal 3, options.count
    noms = options.collect(&:nom)
    assert noms.include? 'Anglais'
    assert noms.include? 'Espagnol'
    assert noms.include? 'Danse'

    eleve1 = Eleve.find_by(identifiant: "1")
    nom_option_eleve1 = eleve1.option.collect(&:nom)
    assert nom_option_eleve1.include? 'Anglais'

    eleve4 = Eleve.find_by(identifiant: "4")
    groupes = eleve4.option.collect(&:groupe)
    assert groupes.include? 'Autres enseignements'
    noms = eleve4.option.collect(&:nom)
    assert noms.include? 'Danse'
  end

  def test_import_dun_fichier_avec_plusieurd_lignes_par_eleve
    nombre_eleves_debut = Eleve.all.count
    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont' }
    etablissement = Etablissement.find_by(nom: 'Collège Germaine Tillion')
    tache_import = TacheImport.create(url: 'test/fixtures/files/test_import_multi_lignes.xlsx', statut: 'en_attente',
      etablissement_id: etablissement.id)
    get '/api/traiter_imports'
    assert_equal 200, response.status

    nombre_eleves_importes = Eleve.all.count - nombre_eleves_debut
    assert_equal 31, nombre_eleves_importes

    eleve = Eleve.find_by(identifiant: '070823218DD')
    assert_equal 2, eleve.option.count
  end

  def test_importe_uniquement_les_adresses
    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont' }
    etablissement = Etablissement.find_by(nom: 'Collège Germaine Tillion')
    TacheImport.create(url: 'test/fixtures/files/test_import_adresses.xlsx', statut: 'en_attente',
      etablissement_id: etablissement.id, traitement: 'tout')
    get '/api/traiter_imports'
    assert_equal 200, response.status

    dossier_eleve1 = Eleve.find_by(identifiant: "070823218DD").dossier_eleve
    resp_legal1 = dossier_eleve1.resp_legal.select { |r| r.lien_de_parente == 'MERE'}.first
    resp_legal1.update(ville: 'Vernon', code_postal: '27200', adresse: 'Route de Magny')

    TacheImport.create(url: 'test/fixtures/files/test_import_adresses.xlsx', statut: 'en_attente',
      etablissement_id: etablissement.id, traitement: 'adresses')
    get '/api/traiter_imports'
    assert_equal 200, response.status

    dossier_eleve1 = Eleve.find_by(identifiant: "070823218DD").dossier_eleve
    resp_legal1 = dossier_eleve1.resp_legal.select { |r| r.lien_de_parente == 'MERE'}.first

    dossier_eleve2 = Eleve.find_by(identifiant: "072342399CH").dossier_eleve
    resp_legal2 = dossier_eleve2.resp_legal.select { |r| r.lien_de_parente == 'MERE'}.first

    assert_equal 'Vernon', resp_legal1.ville
    assert_equal '27200', resp_legal1.code_postal
    assert_equal 'Route de Magny', resp_legal1.adresse
    assert_equal 'PARIS', resp_legal1.ville_ant
    assert_equal '75017', resp_legal1.code_postal_ant
    assert_equal "5 rue VILLARET DE JOYEUSE \n" + " ", resp_legal1.adresse_ant
  end


  def test_creer_des_options
    Option.destroy_all
    etablissement_id = Etablissement.find_by(nom: 'College Jean-Francois Oeben').id
    colonnes_siecle = [
      {libelle: 'ANGLAIS LV1', cle_gestion: 'AGL1', code: 'O',
        nom_attendu: 'Anglais', groupe_attendu: 'Langue vivante 1'},
      {libelle: 'ESPAGNOL LV2', cle_gestion: 'ESP2', code: 'O',
        nom_attendu: 'Espagnol', groupe_attendu: 'Langue vivante 2'},
      {libelle: 'ESPAGNOL LV2 ND', cle_gestion: 'ES2ND', code: 'O',
        nom_attendu: 'Espagnol non débutant', groupe_attendu: 'Langue vivante 2'},
      {libelle: 'ALLEMAND LV2', cle_gestion: 'ALL2', code: 'O',
        nom_attendu: 'Allemand', groupe_attendu: 'Langue vivante 2'},
      {libelle: 'ALLEMAND LV2 ND', cle_gestion: 'AL2ND', code: 'O',
        nom_attendu: 'Allemand non débutant', groupe_attendu: 'Langue vivante 2'},
      {libelle: 'LCA LATIN', cle_gestion: 'LCALA', code: 'F',
        nom_attendu: 'Latin', groupe_attendu: "Langues et cultures de l'antiquité"},
      {libelle: 'LCA GREC', cle_gestion: 'LCAGR', code: 'F',
        nom_attendu: 'Grec', groupe_attendu: "Langues et cultures de l'antiquité"},
    ]

    colonnes_siecle.each do |colonne|
      creer_option colonne[:libelle], colonne[:cle_gestion], colonne[:code]

      option = Option.where(nom: colonne[:nom_attendu], groupe: colonne[:groupe_attendu])
      assert_equal 1, option.count
    end
  end

  def test_compte_taux_de_portables_dans_siecle
    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont' }
    import_siecle_xls = fixture_file_upload('files/test_import_siecle.xls','application/vnd.ms-excel')
    post '/agent/import_siecle', params: { name: 'import_siecle', traitement: 'tout', filename: import_siecle_xls }
    get '/api/traiter_imports'
    get '/agent/import_siecle'
    doc = Nokogiri::HTML(response.body)
    assert_match "100% de téléphones portables", doc.css('.message_de_succes').text
    assert_match "50% d'emails", doc.css('.message_de_succes').text
  end

  def test_un_agent_importe_un_eleve
    nb_eleves_au_depart = Eleve.all.size
    import_siecle_xls = fixture_file_upload('files/test_import_siecle.xls','application/vnd.ms-excel')

    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont' }
    post '/agent/import_siecle', params: { nom_eleve: 'NOM_TEST', prenom_eleve: 'Prenom_test',
         name: 'import_siecle', traitement: 'tout',
         filename: import_siecle_xls }

    agent = Agent.find_by(identifiant: 'pierre')
    tache_import = TacheImport.find_by(statut: 'en_attente',
          etablissement_id: agent.etablissement.id)

    assert_equal('NOM_TEST', tache_import.nom_a_importer)
    assert_equal('Prenom_test', tache_import.prenom_a_importer)

    get '/api/traiter_imports'

    assert_equal nb_eleves_au_depart+1, Eleve.all.size
  end

  def test_options_demande_et_abandon
    eleve = Eleve.create!(identifiant: 'XXX', date_naiss: '1970-01-01')
    eleve.option << Option.create(nom: 'espagnol', groupe: 'lv2')
    eleve.option << Option.create(nom: 'espagnol', groupe: 'lv2')
    latin = Option.create(nom: 'latin', groupe: 'LCA', modalite: 'facultative')
    eleve.option << latin
    grec = Option.create(nom: 'grec', groupe: 'LCA', modalite: 'facultative')

    grec_d = Demande.create(option_id: grec.id, eleve_id: eleve.id)
    latin_a = Abandon.create(option_id: latin.id, eleve_id: eleve.id)

    assert_equal ['espagnol', 'grec (+)', 'latin (-)'], eleve.options_apres_montee
  end

  def test_destinataire_sms
    dossier = DossierEleve.new
    dossier.resp_legal = [RespLegal.new(
      tel_principal: "01 12 34 56 78", tel_secondaire: "06 12 34 56 78", priorite: 1),
      RespLegal.new(
      tel_principal: "01 12 34 56 78", tel_secondaire: "06 12 34 56 99", priorite: 2)]
    message = Message.new(dossier_eleve: dossier, categorie: "sms")
    assert_equal "06 12 34 56 78", message.numero
    message.destinataire = "rl2"
    assert_equal "06 12 34 56 99", message.numero
  end

  def test_portable_rl1
    dossier = DossierEleve.new
    dossier.resp_legal = [RespLegal.new(
      tel_principal: "01 12 34 56 78", tel_secondaire: "06 12 34 56 78", priorite: 1)]
    assert_equal "06 12 34 56 78", dossier.portable_rl1
    dossier.resp_legal = [RespLegal.new(
      tel_principal: "06 12 34 56 78", tel_secondaire: nil, priorite: 1)]
    assert_equal "06 12 34 56 78", dossier.portable_rl1
    dossier.resp_legal = [RespLegal.new(
      tel_principal: "06 12 34 56 78", tel_secondaire: "", priorite: 1)]
    assert_equal "06 12 34 56 78", dossier.portable_rl1
    dossier.resp_legal = [RespLegal.new(
      tel_principal: "06 12 34 56 78", tel_secondaire: "01 12 34 56 78", priorite: 1)]
    assert_equal "06 12 34 56 78", dossier.portable_rl1
    dossier.resp_legal = [RespLegal.new(
      tel_principal: "07 12 34 56 78", tel_secondaire: "06 12 34 56 78", priorite: 1)]
    assert_equal "06 12 34 56 78", dossier.portable_rl1
  end

  def test_portable_rl2
    dossier = DossierEleve.new
    dossier.resp_legal = [RespLegal.new(
      tel_principal: "01 12 34 56 78", tel_secondaire: "06 12 34 56 78", priorite: 1)]
    assert_nil dossier.portable_rl2
    dossier.resp_legal << RespLegal.new(
      tel_principal: "01 12 34 56 78", tel_secondaire: "06 12 34 56 99", priorite: 2)
    assert_equal "06 12 34 56 99", dossier.portable_rl2
  end

  def test_un_visiteur_anonyme_ne_peut_pas_valider_une_piece_jointe
    dossier_eleve = DossierEleve.last
    piece_attendue = PieceAttendue.find_by(code: 'assurance_scolaire',
                                           etablissement_id: dossier_eleve.etablissement.id)
    piece_jointe = PieceJointe.create(clef: 'assurance_scannee.pdf', dossier_eleve_id: dossier_eleve.id,
                                      piece_attendue_id: piece_attendue.id)
    etat_préservé = piece_jointe.etat

    post '/agent/change_etat_fichier', params: {id: piece_jointe.id, etat: 'validé'}

    nouvel_etat_piece = PieceJointe.find(piece_jointe.id).etat
    assert_nil etat_préservé, nouvel_etat_piece
  end

  def test_un_agent_visualise_un_eleve
    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont' }

    get '/agent/eleve/2'

    assert response.body.include? 'Edith'
    assert response.body.include? 'Piaf'
  end

  def test_un_agent_ajoute_une_nouvelle_piece_attendue
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    post '/agent/piece_attendues', params: {nom: 'Photo d’identité', explication: 'Pour coller sur le carnet'}

    post '/identification', params: {identifiant: '5', annee: '1970', mois: '01', jour: '01'}
    get '/pieces_a_joindre'

    assert response.body.include? "Photo d’identité"
  end

end

