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
    post '/agent/import_siecle', params: { name: 'import_siecle', filename: import_siecle_xls }
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
         name: 'import_siecle', filename: import_siecle_xls }

    agent = Agent.find_by(identifiant: 'pierre')
    tache_import = TacheImport.find_by(statut: 'en_attente',
          etablissement_id: agent.etablissement.id)

    assert_equal('NOM_TEST', tache_import.nom_a_importer)
    assert_equal('Prenom_test', tache_import.prenom_a_importer)

    get '/api/traiter_imports'

    assert_equal nb_eleves_au_depart + 1, Eleve.all.size
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

  def test_un_agent_genere_un_pdf
    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont' }

    post '/agent/pdf', params: { identifiant: 3 }

    assert_equal 'application/pdf', response.headers['Content-Type']
  end

  def test_valide_une_inscription
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}

    post '/agent/valider_inscription', params: {identifiant: '4'}
    eleve = Eleve.find_by(identifiant: '4')
    assert_equal 'validé', eleve.dossier_eleve.etat

    get "/agent/eleve/#{eleve.identifiant}"
    doc = Nokogiri::HTML(response.body)
    assert_equal 'disabled', doc.css("#bouton-validation-inscription").first.attributes['disabled'].value
  end

  def test_un_eleve_est_sortant
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}

    post '/agent/eleve_sortant', params: {identifiant: '4'}
    eleve = Eleve.find_by(identifiant: '4')
    assert_equal 'sortant', eleve.dossier_eleve.etat

    get "/agent/eleve/#{eleve.identifiant}"
    doc = Nokogiri::HTML(response.body)
    assert_equal 'disabled', doc.css("#bouton-eleve-sortant").first.attributes['disabled'].value
  end

  def test_liste_des_eleves
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    get '/agent/liste_des_eleves'

    assert response.body.include? "Edith"
    assert response.body.include? "Piaf"
  end

  def test_etat_piece_jointe_liste_des_eleves
    dossier_eleve = Eleve.find_by(identifiant: 2).dossier_eleve
    piece_attendue = PieceAttendue.find_by(code: 'assurance_scolaire',
                                           etablissement_id: dossier_eleve.etablissement.id)
    piece_jointe = PieceJointe.create(clef: 'assurance_scannee.pdf', dossier_eleve_id: dossier_eleve.id,
                                      piece_attendue_id: piece_attendue.id)

    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    post '/agent/change_etat_fichier', params: { id: piece_jointe.id, etat: 'valide'}

    get '/agent/liste_des_eleves'
    assert response.body.include? "fa-file-image"
    assert response.body.include? "fa-check-circle"
  end

  def test_affiche_changement_adresse_liste_eleves
    # Si on a un changement d'adresse
    eleve = Eleve.find_by(identifiant: 2)
    resp_legal = eleve.dossier_eleve.resp_legal_1
    resp_legal.adresse = "Nouvelle adresse"
    resp_legal.save

    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    get '/agent/liste_des_eleves'

    assert response.body.include? "✓"
  end

  def test_affiche_demi_pensionnaire
    eleve = Eleve.find_by(identifiant: 2)
    dossier_eleve = eleve.dossier_eleve
    dossier_eleve.update(demi_pensionnaire: true)

    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont' }
    get '/agent/liste_des_eleves'

    assert response.body.include? "✓"
  end

  def test_affiche_lenvoi_de_message_uniquement_si_un_des_resp_legal_a_un_mail
    e = Eleve.create! identifiant: 'XXX'
    dossier_eleve = DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first.id
    RespLegal.create! dossier_eleve_id: dossier_eleve.id, email: 'test@test.com', priorite: 1

    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont' }
    get "/agent/eleve/XXX"

    assert response.body.include? "Ce formulaire envoie un message à la famille de l'élève."
  end

  def test_affiche_contacts
    e = Eleve.create! identifiant: 'XXX'
    dossier_eleve = DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first.id
    RespLegal.create! dossier_eleve_id: dossier_eleve.id,
                      tel_principal: '0101010101', tel_secondaire: '0606060606', email: 'test@test.com', priorite: 1
    ContactUrgence.create! dossier_eleve_id: dossier_eleve.id, tel_principal: '0103030303'

    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    get "/agent/eleve/XXX"

    assert response.body.include? "0101010101"
    assert response.body.include? "0606060606"
    assert response.body.include? "0103030303"
  end

  def test_affiche_lenveloppe_uniquement_si_un_des_resp_legal_a_un_mail
    e = Eleve.create!(identifiant: 'XXX', date_naiss: '1970-01-01')
    dossier_eleve = DossierEleve.create!(eleve_id: e.id, etablissement_id: Etablissement.first.id)
    resp_legal = RespLegal.create(email: 'test@test.com', dossier_eleve_id: dossier_eleve.id)

    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont' }
    get '/agent/liste_des_eleves'

    assert response.body.include? "far fa-envelope"
  end

  def test_affiche_decompte_historique_message_envoyes
    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont' }
    post '/agent/contacter_une_famille', params: {identifiant: '2', message: 'Message de test'}
    get '/agent/liste_des_eleves'

    assert response.body.include? "(1)"
  end

  def test_changement_statut_famille_connecte
    post '/identification', params: {identifiant: '2', annee: '1915', mois: '12', jour: '19'}
    dossier_eleve = Eleve.find_by(identifiant: '2').dossier_eleve
    assert_equal 'connecté', dossier_eleve.etat

    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont' }
    get '/agent/liste_des_eleves'

    assert response.body.include? "connecté"
  end

  def test_changement_statut_famille_en_cours_de_validation
    post '/identification', params: {identifiant: '2', annee: '1915', mois: '12', jour: '19'}
    post '/validation'
    dossier_eleve = Eleve.find_by(identifiant: '2').dossier_eleve
    assert_equal 'en attente de validation', dossier_eleve.etat

    post '/agent', params: { identifiant: 'pierre', mot_de_passe: 'demaulmont' }
    get '/agent/liste_des_eleves'

    assert response.body.include? "en attente de validation"
  end

  def test_un_agent_envoi_un_mail_a_une_famille
    agent = Agent.find_by(identifiant: 'pierre')
    agent.etablissement.update(email: 'etablissement@email.com')

    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    post '/agent/contacter_une_famille', params: {identifiant: '6', message: 'Message de test'}

    mail = ActionMailer::Base.deliveries.last
    assert_equal 'contact@dossiersco.beta.gouv.fr', mail['from'].to_s
    assert mail['to'].addresses.collect(&:to_s).include? 'test@test.com'
    assert mail['to'].addresses.collect(&:to_s).include? 'test2@test.com'
    assert mail['to'].addresses.collect(&:to_s).include? 'contact@dossiersco.beta.gouv.fr'
    assert mail['reply_to'].addresses.collect(&:to_s).include? 'etablissement@email.com'
    assert mail['reply_to'].addresses.collect(&:to_s).include? 'contact@dossiersco.beta.gouv.fr'
    assert_equal 'Réinscription de votre enfant au collège', mail['subject'].to_s
    part = mail.html_part || mail.text_part || mail
    assert part.body.decoded.include? "Tillion"
    assert part.body.decoded.include? "Emile"
  end

  def test_envoie_par_sms_les_messages_aux_familles_sans_email
    eleve = Eleve.find_by(identifiant: "6")
    eleve.dossier_eleve.resp_legal.each do |rl| rl.update(email: nil) end
    assert_equal 0, Message.where(categorie:"sms").count

    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    post '/agent/contacter_une_famille', params: {identifiant: '6', message: 'Message de test'}

    assert_equal 0, ActionMailer::Base.deliveries.count
    assert_equal 1, Message.where(categorie:"sms").count
  end

  def test_trace_messages_envoyes
    assert_equal 0, Message.count
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    post '/agent/contacter_une_famille', params: {identifiant: '6', message: 'Message de test'}

    eleve = Eleve.find_by(identifiant: "6")
    dossier = eleve.dossier_eleve

    assert_equal 1, Message.count
    message = Message.first
    assert_equal "mail", message.categorie
    assert_equal dossier.id, message.dossier_eleve_id
    assert_equal "envoyé", message.etat
    assert message.contenu.include? "Tillion"
  end

  def test_envoi_un_mail_quand_un_agent_valide_un_dossier
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    post '/agent/valider_inscription', params: {identifiant: '4'}

    mail = ActionMailer::Base.deliveries.last
    assert_equal 'contact@dossiersco.beta.gouv.fr', mail['from'].to_s
    assert mail['to'].addresses.collect(&:to_s).include? 'test@test.com'
    assert mail['to'].addresses.collect(&:to_s).include? 'test2@test.com'
    assert mail['to'].addresses.collect(&:to_s).include? 'contact@dossiersco.beta.gouv.fr'
    assert_equal "Réinscription de votre enfant au collège", mail['subject'].to_s
    part = mail.html_part || mail.text_part || mail
    assert part.body.decoded.include? "Votre enfant est bien inscrit."
    assert part.body.decoded.include? "Pierre"
  end

  def test_lenvoie_dun_email_de_relance
    eleve = Eleve.find_by(identifiant: 2)
    template = "Réinscription de votre enfant <%= eleve.prenom %> <%= eleve.nom %> au collège"
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    post '/agent/relance_emails', params: {ids: eleve.dossier_eleve.id, template: template}

    assert_equal 1, Message.count
    message = Message.first
    message.envoyer

    mail = ActionMailer::Base.deliveries.last
    assert_equal 'contact@dossiersco.beta.gouv.fr', mail['from'].to_s
    assert mail['to'].addresses.collect(&:to_s).include? 'test@test.com'
    assert mail['to'].addresses.collect(&:to_s).include? 'etablissement@email.com'
    assert mail['to'].addresses.collect(&:to_s).include? 'contact@dossiersco.beta.gouv.fr'
    assert mail['reply_to'].addresses.collect(&:to_s).include? 'etablissement@email.com'
    assert mail['reply_to'].addresses.collect(&:to_s).include? 'contact@dossiersco.beta.gouv.fr'
    assert_equal 'Réinscription de votre enfant au collège', mail['subject'].to_s
    part = mail.html_part || mail.text_part || mail
    assert part.body.decoded.include? "Réinscription de votre enfant Edith Piaf au collège"
  end

  def test_stats
    get '/stats'
    doc = Nokogiri::HTML(response.body)
    # Etablissements
    assert_equal Etablissement.count, doc.css(".etablissement").count
    names = doc.css(".etablissement > .row > .nom").collect(&:text).collect(&:strip)
    assert names.include? "Collège Germaine Tillion"
    # Classes - on a 4 classes sur Tillion et 2 sur Oeben dont 2 du même nom entre
    # les deux établissements
    names = doc.css(".etablissement .classe > .row > .nom").collect(&:text).collect(&:strip)
    assert_equal 6, doc.css(".etablissement .classe").count
    assert_equal 2, (names.select {|x| x == "3EME 1"}).count
    # Statuts - 100% de non connectés à Oeben
    pas_connecte = ".etablissement .progress .bg-secondary"
    assert_equal "2", doc.css(pas_connecte).first.text().strip
    assert_equal "width: 100.0%;", doc.css(pas_connecte)[1].attr("style")
  end

  def test_page_eleve_agent_affiche_changement_adresse
    resp_legal_1 = Eleve.find_by(identifiant: '2').dossier_eleve.resp_legal_1
    resp_legal_1.update adresse: 'Nouvelle adresse'

    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}

    get '/agent/eleve/2'

    doc = Nokogiri::HTML(response.body)
    assert_not_nil doc.css("div#ancienne_adresse").first
  end

  def test_page_eleve_agent_affiche_adresse_sans_changement
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}

    get '/agent/eleve/2'

    doc = Nokogiri::HTML(response.body)
    assert_nil doc.css("div#ancienne_adresse").first
  end

  def test_un_agent_voit_un_commentaire_parent_dans_vue_eleve
    e = Eleve.create! identifiant: 'XXX'
    d = DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first.id, commentaire: "Commentaire de test"
    RespLegal.create! dossier_eleve_id: d.id,
                      tel_principal: '0101010101', tel_secondaire: '0606060606', email: 'test@test.com', priorite: 1

    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    get "/agent/eleve/XXX"

    doc = Nokogiri::HTML(response.body)
    assert_equal "#{d.satisfaction} : Commentaire de test", doc.css("div#commentaire").first.text
  end

  def test_historique_messages_envoyes
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    post '/agent/contacter_une_famille', params: {identifiant: '2', message: 'Message 1'}
    post '/agent/contacter_une_famille', params: {identifiant: '2', message: 'Message 2'}
    get "/agent/eleve/2"
    doc = Nokogiri::HTML(response.body)
    assert_equal 2, doc.css("#historique div.message").count
    assert doc.css("#historique div.message:nth-child(1) .card-body").text.strip.include? "Message 1"
    assert doc.css("#historique div.message:nth-child(2) .card-body").text.strip.include? "Message 2"
  end

  def test_la_validation_de_plusieurs_dossiers_eleve
    eleve1 = Eleve.create!(identifiant: 'test1', date_naiss: '1970-01-01')
    dossier_eleve1 = DossierEleve.create!(eleve_id: eleve1.id, etablissement_id: Etablissement.first.id,
                                          etat: "en attente de validation")
    eleve2 = Eleve.create!(identifiant: 'test2', date_naiss: '1970-01-01')
    dossier_eleve2 = DossierEleve.create!(eleve_id: eleve2.id, etablissement_id: Etablissement.first.id,
                                          etat: "en attente de validation")
    ids = [dossier_eleve1.id.to_s, dossier_eleve2.id.to_s]

    assert_equal 0, ActionMailer::Base.deliveries.count

    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    post '/agent/valider_plusieurs_dossiers', params: {ids: ids}

    assert_equal 2, ActionMailer::Base.deliveries.count

    dossier_eleve1 = DossierEleve.find(dossier_eleve1.id)
    dossier_eleve2 = DossierEleve.find(dossier_eleve2.id)

    assert_equal 'validé', dossier_eleve2.etat
    assert_equal 'validé', dossier_eleve1.etat
  end

  def test_propose_modeles_messages
    modele = Modele.create(nom: "Cantine")
    Agent.find_by(identifiant: "pierre").etablissement.modele << modele
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    get '/agent/eleve/4'

    doc = Nokogiri::HTML(response.body)
    assert_equal 'Cantine', doc.css('select#modeles option').text
    assert_equal modele.id.to_s, doc.css('select#modeles option').attr("value").text
  end

  def test_rendu_modele
    skip("manipulation des templates / render dans le controller à revoir")
    modele = Modele.create(nom: "Cantine", contenu: "Salut <%= eleve.prenom %>")
    Agent.find_by(identifiant: "pierre").etablissement.modele << modele
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    get "/agent/fusionne_modele/#{modele.id}/eleve/4"
    assert_equal "Salut Pierre", response.body
  end

  def test_affiche_options
    eleve1 = Eleve.find_by(nom: 'Piaf')
    eleve2 = Eleve.find_by(identifiant: 3)
    eleve2.dossier_eleve.update(etat: 'sortant')
    latin = Option.create(nom: 'latin', groupe: 'LCA')
    eleve1.option << latin
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}

    get '/agent/options'

    assert ! response.body.include?(eleve2.prenom)
    assert response.body.include? "latin"
  end

  def test_liste_resp_legaux
    eleve = Eleve.find_by(nom: 'Piaf')
    eleve.dossier_eleve.update(etat: "pas connecté")
    eleve_2 = Eleve.find_by(nom: 'Blayo')
    eleve_2.dossier_eleve.update(etat: "connecté")
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}

    get '/agent/convocations'

    resp_legal_1 = eleve.dossier_eleve.resp_legal.find {|d| d.priorite == 1}
    resp_legal_1_eleve_2 = eleve_2.dossier_eleve.resp_legal.find {|d| d.priorite == 1}
    doc = Nokogiri::HTML(response.body)
    assert_equal resp_legal_1.prenom, doc.css("tbody > tr:nth-child(1) > td:nth-child(4)").text.strip
    assert_equal resp_legal_1.nom, doc.css("tbody > tr:nth-child(1) > td:nth-child(5)").text.strip
    assert_equal resp_legal_1.tel_principal, doc.css("tbody > tr:nth-child(1) > td:nth-child(6)").text.strip
    assert_equal resp_legal_1.tel_secondaire, doc.css("tbody > tr:nth-child(1) > td:nth-child(7)").text.strip
    assert_equal resp_legal_1_eleve_2.prenom, doc.css("tbody > tr:nth-child(2) > td:nth-child(4)").text.strip
  end
end

