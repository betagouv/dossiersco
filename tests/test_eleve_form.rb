ENV['RACK_ENV'] = 'test'

require 'nokogiri'
require 'test/unit'
require 'rack/test'
require 'tempfile'

require_relative '../helpers/singulier_francais'

require_relative '../dossiersco_web'
require_relative '../dossiersco_agent'

class EleveFormTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include MotDePasse

  def app
    Sinatra::Application
  end

  def setup
    ActiveRecord::Schema.verbose = false
    require_relative "../db/schema.rb"
    init
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.deliveries = []
  end

  def test_normalise_date_naissance
    assert_equal "2018-05-14", normalise("14 05 2018")
    assert_equal "2018-05-14", normalise("14/05/2018")
    assert_equal "2018-01-01", normalise("1/1/2018")
    assert_equal "2018-05-14", normalise("___14!___05_A_2018_")
    assert_equal "2018-05-14", normalise("14052018_")
    assert_equal nil, normalise("foo")
  end

  def test_message_erreur_identification
    assert_equal 'Veuillez fournir identifiant et date de naissance', message_erreur_identification(nil, '14-05-2018')
    assert_equal 'Veuillez fournir identifiant et date de naissance', message_erreur_identification('', '14-05-2018')
    assert_equal 'Veuillez fournir identifiant et date de naissance', message_erreur_identification('XXX', nil)
    assert_equal 'Veuillez fournir identifiant et date de naissance', message_erreur_identification('XXX', '')
  end

  def test_accueil
    get '/'
    assert last_response.body.include? 'Inscription'
  end

  def test_entree_succes_eleve_1
    post '/identification', identifiant: '1', date_naiss: '1995-11-19'
    follow_redirect!
    assert last_response.body.include? 'Pour réinscrire votre enfant'
  end

  def test_entree_succes_firefox_52_0_1_eleve_1
    post '/identification', identifiant: '1', date_naiss: '19/11/1995'
    follow_redirect!
    assert last_response.body.include? 'Pour réinscrire votre enfant'
  end


  def test_entree_succes_date_avec_espaces_eleve_1
    post '/identification', identifiant: '1', date_naiss: '19 11 1995'
    follow_redirect!
    assert last_response.body.include? 'Pour réinscrire votre enfant'
  end

  def test_entree_mauvaise_date
    post '/identification', identifiant: '3', date_naiss: '1995-11-19'
    follow_redirect!
    assert last_response.body.include? "Nous n'avons pas reconnu ces identifiants, merci de les vérifier."
  end

  def test_entree_mauvais_identifiant_et_date
    post '/identification', identifiant: 'toto', date_naiss: 'foo'
    follow_redirect!
    assert last_response.body.include? "Nous n'avons pas reconnu ces identifiants, merci de les vérifier."
  end

  def test_nom_college_accueil
    post '/identification', identifiant: '1', date_naiss: '1995-11-19'
    follow_redirect!
    doc = Nokogiri::HTML(last_response.body)
    assert_equal 'College Jean-Francois Oeben', doc.xpath("//div//h1/text()").to_s
    assert_equal 'College Jean-Francois Oeben.', doc.xpath("//strong[@id='etablissement']/text()").to_s.strip
    assert_equal 'samedi 3 juin 2018', doc.xpath("//strong[@id='date-limite']/text()").to_s
  end

  def test_modification_lieu_naiss_eleve
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    post '/eleve', ville_naiss: 'Beziers', prenom: 'Edith'
    get '/eleve'
    assert last_response.body.include? 'Edith'
    assert last_response.body.include? 'Beziers'
  end

  def test_modifie_une_information_de_eleve_preserve_les_autres_informations
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    post '/eleve', prenom: 'Edith'
    get '/eleve'
    assert last_response.body.include? 'Piaf'
  end

  def test_affiche_2ème_et_3ème_prénoms_en_4ème_pour_brevet_des_collèges
    post '/identification', identifiant: '4', date_naiss: '1970-01-01'
    get '/eleve'
    assert last_response.body.include? 'Deuxième prénom'
    assert last_response.body.include? 'Troisième prénom'
  end

  def test_n_affiche_pas_2ème_et_3ème_prénoms_en_5ème
    post '/identification', identifiant: '5', date_naiss: '1970-01-01'
    get '/eleve'
    assert_no_match /Deuxième prénom/, last_response.body
    assert_no_match /Troisième prénom/, last_response.body
  end

  def test_n_affiche_pas_2ème_et_3ème_prénoms_en_6ème
    post '/identification', identifiant: '6', date_naiss: '1970-01-01'
    get '/eleve'
    assert_no_match /Deuxième prénom/, last_response.body
    assert_no_match /Troisième prénom/, last_response.body
  end

  def test_affiche_2ème_et_3ème_prénoms_en_CM2
    post '/identification', identifiant: '1', date_naiss: '1995-11-19'
    get '/eleve'
    assert last_response.body.include? 'Deuxième prénom'
    assert last_response.body.include? 'Troisième prénom'
  end

  def test_accueil_et_inscription
    post '/identification', identifiant: '1', date_naiss: '1995-11-19'
    follow_redirect!
    assert last_response.body.include? 'inscription'
  end

  def test_dossier_eleve_possede_un_contact_urgence
    dossier_eleve = DossierEleve.first

    ContactUrgence.update dossier_eleve_id: dossier_eleve.id, tel_principal: "0123456789"

    assert dossier_eleve.contact_urgence.tel_principal == "0123456789"
  end

  def test_persistence_du_resp_legal_1
    doc = soumet_formulaire '/famille',
                            lien_de_parente_rl1: "Tutrice", prenom_rl1: "Philippe", nom_rl1: "Blayo",
                            adresse_rl1: "20 bd Segur", code_postal_rl1: "75007", ville_rl1: "Paris",
                            tel_principal_rl1: "0612345678", tel_secondaire_rl1: "0112345678",
                            email_rl1: "test@gmail.com", situation_emploi_rl1: "Pré retraité, retraité ou retiré",
                            profession_rl1: "Retraité cadre, profession interm édiaire",
                            enfants_a_charge_secondaire_rl1: 2, enfants_a_charge_rl1: 3,
                            communique_info_parents_eleves_rl1: 'true'

    assert_attr 'Tutrice', '#lien_de_parente_rl1', doc
    assert_attr 'Philippe', '#prenom_rl1', doc
    assert_attr 'Blayo', '#nom_rl1', doc
    assert_attr '20 bd Segur', '#adresse_rl1', doc
    assert_attr '75007', '#code_postal_rl1', doc
    assert_attr 'Paris', '#ville_rl1', doc
    assert_attr '0612345678', '#tel_principal_rl1', doc
    assert_attr '0112345678', '#tel_secondaire_rl1', doc
    assert_attr 'test@gmail.com', '#email_rl1', doc
    assert_equal 'Pré retraité, retraité ou retiré', doc.css('#situation_emploi_rl1 option[@selected="selected"]').children.text
    assert_equal 'Retraité cadre, profession interm édiaire', doc.css('#profession_rl1 option[@selected="selected"]').children.text
    assert_attr '2', '#enfants_a_charge_secondaire_rl1', doc
    assert_attr '3', '#enfants_a_charge_rl1', doc
    assert_equal 'checked', doc.css('#communique_info_parents_eleves_rl1_true').attr('checked').text
  end

  def test_persistence_du_resp_legal_2
    doc = soumet_formulaire  '/famille',
                             lien_de_parente_rl2: "Tutrice", prenom_rl2: "Philippe" , nom_rl2: "Blayo",
                             adresse_rl2: "20 bd Segur",code_postal_rl2: "75007", ville_rl2: "Paris",
                             tel_principal_rl2: "0612345678", tel_secondaire_rl2: "0112345678",
                             email_rl2: "test@gmail.com", situation_emploi_rl2: "Pré retraité, retraité ou retiré",
                             profession_rl2: "Retraité cadre, profession interm édiaire",
                             communique_info_parents_eleves_rl2: 'true'

    assert_attr 'Tutrice', '#lien_de_parente_rl2', doc
    assert_attr 'Philippe', '#prenom_rl2', doc
    assert_attr 'Blayo', '#nom_rl2', doc
    assert_attr '20 bd Segur', '#adresse_rl2', doc
    assert_attr '75007', '#code_postal_rl2', doc
    assert_attr 'Paris', '#ville_rl2', doc
    assert_attr '0612345678', '#tel_principal_rl2', doc
    assert_attr '0112345678', '#tel_secondaire_rl2', doc
    assert_attr 'test@gmail.com', '#email_rl2', doc
    assert_equal 'Pré retraité, retraité ou retiré', doc.css('#situation_emploi_rl2 option[@selected="selected"]').children.text
    assert_equal 'Retraité cadre, profession interm édiaire', doc.css('#profession_rl2 option[@selected="selected"]').children.text
    assert_equal 'checked', doc.css('#communique_info_parents_eleves_rl2_true').attr('checked').text
  end

  def test_persistence_du_contact_urg
    doc = soumet_formulaire '/famille',
                            lien_avec_eleve_urg: "Tuteur", prenom_urg: "Philippe" , nom_urg: "Blayo",
                            tel_principal_urg: "0612345678", tel_secondaire_urg: "0112345678"

    assert_attr 'Tuteur', '#lien_avec_eleve_urg', doc
    assert_attr 'Philippe', '#prenom_urg', doc
    assert_attr 'Blayo', '#nom_urg', doc
    assert_attr '0612345678', '#tel_principal_urg', doc
    assert_attr '0112345678', '#tel_secondaire_urg', doc
  end

  def test_changement_adresse
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    get '/famille'
    doc = Nokogiri::HTML(last_response.body)
    donnees = reinjecte_donnees_formulaire_famille doc

    # Pas de changement d'adresse
    donnees['tel_principal_rl1'] = "Changement de numéro"
    doc = soumet_formulaire '/famille', donnees

    eleve = Eleve.find_by(identifiant: 2)
    assert !eleve.dossier_eleve.resp_legal_1.changement_adresse

    # Changement d'adresse
    donnees['adresse_rl1'] = "Nouvelle adresse"
    doc = soumet_formulaire '/famille', donnees

    eleve = Eleve.find_by(identifiant: 2)
    assert eleve.dossier_eleve.resp_legal_1.changement_adresse
  end

  def reinjecte_donnees_formulaire_famille doc
    champs = [:lien_de_parente, :prenom, :nom, :adresse, :code_postal, :ville,
              :tel_principal, :tel_secondaire, :email]

    donnees = {}
    champs.each do |champ|
      ['rl1','rl2'].each do |rl|
        champ_qualifie = "#{champ}_#{rl}"
        selecteur = "\##{champ_qualifie}"
        valeur = doc.css(selecteur).attr('value').text if doc.css(selecteur).attr('value')
        valeur = doc.css(selecteur).text if !doc.css(selecteur).attr('value')
        donnees[champ_qualifie] = valeur
      end
    end
    donnees
  end

  def test_affichage_preview_jpg_famille
    eleve = Eleve.find_by(identifiant: 6)
    piece_attendue = PieceAttendue.find_by(code: 'assurance_scolaire',
      etablissement_id: eleve.dossier_eleve.etablissement.id)
    piece_jointe = PieceJointe.create(clef: 'assurance_photo.jpg', dossier_eleve_id: eleve.dossier_eleve.id,
      piece_attendue_id: piece_attendue.id)
    post '/identification', identifiant: '6', date_naiss: '1970-01-01'
    get '/pieces_a_joindre'
    doc = Nokogiri::HTML(last_response.body)
    documents_route = FichierUploader::route_lecture '6', 'assurance_scolaire'
    expected_url = documents_route+"/assurance_photo.jpg"
    assert_equal "background-image: url('#{expected_url}'); height: 200px; max-width: 350px;",
                 doc.css("#image_assurance_scolaire").attr("style").text
    assert doc.css('#image_assurance_scolaire').attr("class").text.split.include?("lien-piece-jointe")
    assert_equal "modal", doc.css('#image_assurance_scolaire').attr("data-toggle").text
    assert_equal "#modal-pieces-jointes", doc.css('#image_assurance_scolaire').attr("data-target").text
    assert_equal expected_url, doc.css('#image_assurance_scolaire').attr("data-url").text
  end

  def test_affichage_preview_pdf_famille
    eleve = Eleve.find_by(identifiant: 6)
    piece_attendue = PieceAttendue.find_by(code: 'assurance_scolaire',
      etablissement_id: eleve.dossier_eleve.etablissement.id)
    piece_jointe = PieceJointe.create(clef: 'assurance_scannee.pdf', dossier_eleve_id: eleve.dossier_eleve.id,
      piece_attendue_id: piece_attendue.id)
    post '/identification', identifiant: '6', date_naiss: '1970-01-01'
    get '/pieces_a_joindre'
    doc = Nokogiri::HTML(last_response.body)
    documents_route = FichierUploader::route_lecture '6', 'assurance_scolaire'
    expected_url = documents_route+"/assurance_scannee.pdf"
    assert_equal "background-image: url('/images/document-pdf.png'); height: 200px; max-width: 350px;",
                 doc.css("#image_assurance_scolaire").attr("style").text
    assert doc.css('#image_assurance_scolaire').attr("class").text.split.include?("lien-piece-jointe")
    assert_equal "modal", doc.css('#image_assurance_scolaire').attr("data-toggle").text
    assert_equal "#modal-pieces-jointes", doc.css('#image_assurance_scolaire').attr("data-target").text
    assert_equal expected_url, doc.css('#image_assurance_scolaire').attr("data-url").text
  end

  def test_ramène_parent_à_dernière_étape_incomplète
    post '/identification', identifiant: '6', date_naiss: '1970-01-01'
    post '/eleve', Espagnol: true, Latin: true

    post '/identification', identifiant: '6', date_naiss: '1970-01-01'
    follow_redirect!

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "Famille : Responsable légal 1", doc.css("body > main > div.col-12 > h2").text
  end

  def test_envoyer_un_mail_quand_la_demande_dinscription_est_valide
    post '/identification', identifiant: '4', date_naiss: '1970-01-01'
    post '/validation'

    mail = ActionMailer::Base.deliveries.last
    assert_equal 'contact@dossiersco.beta.gouv.fr', mail['from'].to_s
    assert mail['to'].addresses.collect(&:to_s).include? 'test@test.com'
    assert mail['to'].addresses.collect(&:to_s).include? 'test2@test.com'
    assert mail['to'].addresses.collect(&:to_s).include? 'contact@dossiersco.beta.gouv.fr'
    assert_equal "Réinscription de votre enfant au collège", mail['subject'].to_s
    part = mail.html_part || mail.text_part || mail
    assert part.body.decoded.include? "réinscription de votre enfant Pierre Blayo"
    assert part.body.decoded.include? "Tillion"
  end

  def soumet_formulaire(*arguments_du_post)
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    post *arguments_du_post
    get arguments_du_post[0]
    Nokogiri::HTML(last_response.body)
  end

  def test_affichage_des_options_choisis_sur_la_page_validation
    eleve = Eleve.create(identifiant: 'xxx', date_naiss: '1970-01-01', niveau_classe_ant: '3')
    etablissement = Etablissement.create(nom: 'college test')
    dossier_eleve = DossierEleve.create(eleve_id: eleve.id, etablissement_id: etablissement.id)
    eleve.option << Option.create(nom: 'anglais', groupe: 'LV1')
    option_choisie = Option.create(nom: 'grec', groupe: 'LCA')
    demande = Demande.create(option_id: option_choisie.id, eleve_id: eleve.id)
    option_abandonnee = Option.create(nom: 'latin', groupe: 'LCA')
    abandon = Abandon.create(option_id: option_abandonnee.id, eleve_id: eleve.id)

    post '/identification', identifiant: 'xxx', date_naiss: '1970-01-01'
    get '/validation'

    assert last_response.body.include? 'anglais'
    assert last_response.body.include? "Je demande l'inscription à l'option <strong>grec</strong>"
    assert last_response.body.include? "Je souhaite me désister de l'option <strong>latin</strong>"
  end

  def test_affichage_info_sur_options
    eleve = Eleve.find_by(identifiant: 6)
    eleve.update(montee: Montee.create)
    option = Option.create(nom: 'grec', groupe: 'LCA', modalite:'facultative', info: '(sous réserve)')
    demandabilite = Demandabilite.create(option: option, montee: eleve.montee)
    demande = Demande.create(option_id: option.id, eleve_id: eleve.id)

    post '/identification', identifiant: '6', date_naiss: '1970-01-01'

    get '/validation'
    assert last_response.body.include? "Je demande l'inscription à l'option <strong>grec</strong>"

    get '/eleve'
    assert last_response.body.include? 'grec (sous réserve)'
  end


##############################################################################
#   Tests agents
##############################################################################

  def test_entree_succes_agent
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    follow_redirect!
    assert last_response.body.include? 'Collège Germaine Tillion'
  end

  def test_entree_mauvais_mdp_agent
    post '/agent', identifiant: 'pierre', mot_de_passe: 'pierre'
    follow_redirect!
    assert last_response.body.include? 'Ces informations ne correspondent pas à un agent enregistré'
  end

  def test_entree_mauvais_identifiant_agent
    post '/agent', identifiant: 'jacques', mot_de_passe: 'pierre'
    follow_redirect!
    assert last_response.body.include? 'Ces informations ne correspondent pas à un agent enregistré'
  end

  def test_nombre_dossiers_total
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    follow_redirect!
    doc = Nokogiri::HTML(last_response.body)
    selector = '#total_dossiers'
    affichage_total_dossiers = doc.css(selector).text
    assert_equal '5', affichage_total_dossiers
  end

  def test_singularize_dossier_eleve
    assert_equal 'dossier_eleves', 'dossier_eleves'.singularize
  end

  def test_importe_eleve_fichier_siecle
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/import_siecle', nom_eleve: "", prenom_eleve: "", name: 'import_siecle',
         filename: Rack::Test::UploadedFile.new("tests/test_import_siecle.xls")

    doc = Nokogiri::HTML(last_response.body)
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
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    get '/agent/import_siecle'
    doc = Nokogiri::HTML(last_response.body)
    assert_match "L'import de cette base est en cours.", doc.css('.statut-import').text
    assert_empty doc.css("button[type=submit]")
  end

  def test_traiter_zero_imports
    get '/api/traiter_imports'
    assert_equal 200, last_response.status
  end

  def test_traiter_import_eleve_fichier_siecle
    nombre_eleves_debut = Eleve.all.count
    etablissement = Etablissement.find_by(nom: 'Collège Germaine Tillion')
    tache_import = TacheImport.create(url: 'tests/test_import_siecle.xls', statut: 'en_attente',
      etablissement_id: etablissement.id)
    get '/api/traiter_imports'
    assert_equal 200, last_response.status

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
    assert_equal(tache_import.url, 'tests/test_import_siecle.xls')
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
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    etablissement = Etablissement.find_by(nom: 'Collège Germaine Tillion')
    tache_import = TacheImport.create(url: 'tests/test_import_multi_lignes.xlsx', statut: 'en_attente',
      etablissement_id: etablissement.id)
    get '/api/traiter_imports'
    assert_equal 200, last_response.status

    nombre_eleves_importes = Eleve.all.count - nombre_eleves_debut
    assert_equal 31, nombre_eleves_importes

    eleve = Eleve.find_by(identifiant: '070823218DD')
    assert_equal 2, eleve.option.count
  end

  def test_importe_uniquement_les_adresses
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    etablissement = Etablissement.find_by(nom: 'Collège Germaine Tillion')
    TacheImport.create(url: 'tests/test_import_adresses.xlsx', statut: 'en_attente',
      etablissement_id: etablissement.id, traitement: 'tout')
    get '/api/traiter_imports'
    assert_equal 200, last_response.status

    dossier_eleve1 = Eleve.find_by(identifiant: "070823218DD").dossier_eleve
    resp_legal1 = dossier_eleve1.resp_legal.select { |r| r.lien_de_parente == 'MERE'}.first
    resp_legal1.update(ville: 'Vernon', code_postal: '27200', adresse: 'Route de Magny')

    TacheImport.create(url: 'tests/test_import_adresses.xlsx', statut: 'en_attente',
      etablissement_id: etablissement.id, traitement: 'adresses')
    get '/api/traiter_imports'
    assert_equal 200, last_response.status

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
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/import_siecle', name: 'import_siecle', traitement: 'tout', filename: Rack::Test::UploadedFile.new("tests/test_import_siecle.xls")
    get '/api/traiter_imports'
    get '/agent/import_siecle'
    doc = Nokogiri::HTML(last_response.body)
    assert_match "100% de téléphones portables", doc.css('.message_de_succes').text
    assert_match "50% d'emails", doc.css('.message_de_succes').text
  end

  def test_un_visiteur_anonyme_ne_peut_pas_valider_une_piece_jointe
    dossier_eleve = DossierEleve.last
    piece_attendue = PieceAttendue.find_by(code: 'assurance_scolaire',
      etablissement_id: dossier_eleve.etablissement.id)
    piece_jointe = PieceJointe.create(clef: 'assurance_scannee.pdf', dossier_eleve_id: dossier_eleve.id,
      piece_attendue_id: piece_attendue.id)
    etat_préservé = piece_jointe.etat

    post '/agent/change_etat_fichier', id: piece_jointe.id, etat: 'validé'

    nouvel_etat_piece = PieceJointe.find(piece_jointe.id).etat
    assert_equal etat_préservé, nouvel_etat_piece
  end

  def test_un_agent_visualise_un_eleve
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    get '/agent/eleve/2'

    assert last_response.body.include? 'Edith'
    assert last_response.body.include? 'Piaf'
  end

  def test_un_agent_importe_un_eleve
    nb_eleves_au_depart = Eleve.all.size

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/import_siecle', nom_eleve: 'NOM_TEST', prenom_eleve: 'Prenom_test',
         name: 'import_siecle', traitement: 'tout',
         filename: Rack::Test::UploadedFile.new("tests/test_import_siecle.xls")

    agent = Agent.find_by(identifiant: 'pierre')
    tache_import = TacheImport.find_by(statut: 'en_attente',
          etablissement_id: agent.etablissement.id)

    assert_equal('NOM_TEST', tache_import.nom_a_importer)
    assert_equal('Prenom_test', tache_import.prenom_a_importer)

    get '/api/traiter_imports'

    assert_equal nb_eleves_au_depart+1, Eleve.all.size
  end

  def test_une_famille_remplit_letape_administration
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    get '/administration'
    post '/administration', demi_pensionnaire: true, autorise_sortie: true,
      renseignements_medicaux: true, autorise_photo_de_classe: false
    get '/administration'

    assert last_response.body.gsub(/\s/,'').include? "id='demi_pensionnaire' checked".gsub(/\s/,'')
    assert last_response.body.gsub(/\s/,'').include? "id='autorise_sortie' checked".gsub(/\s/,'')
    assert last_response.body.gsub(/\s/,'').include? "id='renseignements_medicaux' checked".gsub(/\s/,'')
    assert last_response.body.gsub(/\s/,'').include? "id='autorise_photo_de_classe' checked".gsub(/\s/,'')
  end

  def test_un_agent_ajoute_une_nouvelle_piece_attendue
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    post '/agent/piece_attendues', nom: 'Photo d’identité', explication: 'Pour coller sur le carnet'

    post '/identification', identifiant: '5', date_naiss: '1970-01-01'
    get '/pieces_a_joindre'
    assert_match /Photo d’identité/, last_response.body
  end

  def test_un_agent_genere_un_pdf
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    post '/agent/pdf', identifiant: 3

    assert_equal 'application/pdf', last_response.original_headers['Content-Type']
  end

  def test_valide_une_inscription
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    post '/agent/valider_inscription', identifiant: '4'
    eleve = Eleve.find_by(identifiant: '4')
    assert_equal 'validé', eleve.dossier_eleve.etat

    get "/agent/eleve/#{eleve.identifiant}"
    doc = Nokogiri::HTML(last_response.body)
    assert_equal 'disabled', doc.css("#bouton-validation-inscription").first.attributes['disabled'].value
  end

  def test_un_eleve_est_sortant
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    post '/agent/eleve_sortant', identifiant: '4'
    eleve = Eleve.find_by(identifiant: '4')
    assert_equal 'sortant', eleve.dossier_eleve.etat

    get "/agent/eleve/#{eleve.identifiant}"
    doc = Nokogiri::HTML(last_response.body)
    assert_equal 'disabled', doc.css("#bouton-eleve-sortant").first.attributes['disabled'].value
  end

  # def test_liste_classes
  #   post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
  #   get '/agent/liste_des_eleves'

  #   doc = Nokogiri::HTML(last_response.body)
  #   assert doc.css("select[name='classes'] option").collect(&:text).include? "6EME"
  #   assert doc.css("select[name='classes'] option").collect(&:text).include? "4EME ULIS"
  # end

  def test_liste_des_eleves
    eleve = Eleve.find_by(identifiant: 2)

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/liste_des_eleves'
    doc = Nokogiri::HTML(last_response.body)
    assert_equal "Edith", doc.css("##{eleve.dossier_eleve.id} td:nth-child(2)").text.strip
    assert_equal "Piaf", doc.css("##{eleve.dossier_eleve.id} td:nth-child(3)").text.strip
  end

  def test_etat_piece_jointe_liste_des_eleves
    dossier_eleve = Eleve.find_by(identifiant: 2).dossier_eleve
    piece_attendue = PieceAttendue.find_by(code: 'assurance_scolaire',
      etablissement_id: dossier_eleve.etablissement.id)
    piece_jointe = PieceJointe.create(clef: 'assurance_scannee.pdf', dossier_eleve_id: dossier_eleve.id,
      piece_attendue_id: piece_attendue.id)

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/change_etat_fichier', id: piece_jointe.id, etat: 'valide'

    get '/agent/liste_des_eleves'
    doc = Nokogiri::HTML(last_response.body)
    assert doc.css("##{dossier_eleve.id} td:nth-child(8) a i.fa-file-image").present?
    assert_equal "color: #00cf00", doc.css("##{dossier_eleve.id} td:nth-child(8) i.fa-check-circle").attr("style").text
  end

  def test_affiche_changement_adresse_liste_eleves
    # Si on a un changement d'adresse
    eleve = Eleve.find_by(identifiant: 2)
    resp_legal = eleve.dossier_eleve.resp_legal_1
    resp_legal.adresse = "Nouvelle adresse"
    resp_legal.save

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/liste_des_eleves'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "✓", doc.css("tbody > tr:nth-child(1) > td:nth-child(6)").text.strip
  end

  def test_affiche_demi_pensionnaire
    eleve = Eleve.find_by(identifiant: 2)
    dossier_eleve = eleve.dossier_eleve
    dossier_eleve.update(demi_pensionnaire: true)

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/liste_des_eleves'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "✓", doc.css("tbody > tr:nth-child(1) > td:nth-child(6)").text.strip
  end

  def test_affiche_lenvoi_de_message_uniquement_si_un_des_resp_legal_a_un_mail
    e = Eleve.create! identifiant: 'XXX'
    dossier_eleve = DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first
    RespLegal.create! dossier_eleve_id: dossier_eleve.id, email: 'test@test.com', priorite: 1

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get "/agent/eleve/XXX"

    assert last_response.body.include? "Ce formulaire envoie un message à la famille de l'élève."
  end

  def test_affiche_contacts
    e = Eleve.create! identifiant: 'XXX'
    dossier_eleve = DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first
    RespLegal.create! dossier_eleve_id: dossier_eleve.id,
      tel_principal: '0101010101', tel_secondaire: '0606060606', email: 'test@test.com', priorite: 1
    ContactUrgence.create! dossier_eleve_id: dossier_eleve.id, tel_principal: '0103030303'

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get "/agent/eleve/XXX"

    assert last_response.body.include? "0101010101"
    assert last_response.body.include? "0606060606"
    assert last_response.body.include? "0103030303"
  end

  def test_affiche_lenveloppe_uniquement_si_un_des_resp_legal_a_un_mail
    e = Eleve.create!(identifiant: 'XXX', date_naiss: '1970-01-01')
    dossier_eleve = DossierEleve.create!(eleve_id: e.id, etablissement_id: Etablissement.first.id)
    resp_legal = RespLegal.create(email: 'test@test.com', dossier_eleve_id: dossier_eleve.id)

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/liste_des_eleves'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "far fa-envelope", doc.css("tbody > tr:nth-child(1) > td").last.children[1].children[0].attributes['class'].value
  end

  def test_changement_statut_famille_connecte
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    dossier_eleve = Eleve.find_by(identifiant: '2').dossier_eleve
    assert_equal 'connecté', dossier_eleve.etat

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/liste_des_eleves'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "connecté", doc.css("tbody > tr:nth-child(1) > td:nth-child(4)").text.strip
  end

  def test_changement_statut_famille_en_cours_de_validation
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    post '/validation'
    dossier_eleve = Eleve.find_by(identifiant: '2').dossier_eleve
    assert_equal 'en attente de validation', dossier_eleve.etat

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/liste_des_eleves'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "en attente de validation", doc.css("tbody > tr:nth-child(1) > td:nth-child(4)").text.strip
  end

  def test_une_personne_non_identifiée_ne_peut_accéder_à_pièces
    get "/piece/6/assurance_scolaire/nimportequoi"

    assert_equal 302, last_response.status
  end

  def test_famille_peut_accéder_à_une_pièce_de_son_dossier
    post '/identification', identifiant: '6', date_naiss: '1970-01-01'

    piece_a_joindre = Tempfile.new('fichier_temporaire')

    post '/enregistre_piece_jointe', assurance_scolaire: {"tempfile": piece_a_joindre.path}

    get "/piece/6/assurance_scolaire/#{File.basename(piece_a_joindre.path)}"

    assert_equal 200, last_response.status
  end

  def test_mailer
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    ActionMailer::Base.delivery_method = :test
    get '/agent/testmail/DossierSCO'
    mail = ActionMailer::Base.deliveries.last
    assert_equal 'contact@dossiersco.beta.gouv.fr', mail['from'].to_s
    assert_equal 'contact@dossiersco.beta.gouv.fr', mail['to'].to_s
    assert_equal 'Test', mail['subject'].to_s
    part = mail.html_part || mail.text_part || mail
    assert part.body.decoded.include? "Bonjour DossierSCO"
  end

  def test_un_agent_envoi_un_mail_a_une_famille
    agent = Agent.find_by(identifiant: 'pierre')
    agent.etablissement.update(email: 'etablissement@email.com')

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/contacter_une_famille', identifiant: '6', message: 'Message de test'

    mail = ActionMailer::Base.deliveries.last
    assert_equal 'contact@dossiersco.beta.gouv.fr', mail['from'].to_s
    assert mail['to'].addresses.collect(&:to_s).include? 'test@test.com'
    assert mail['to'].addresses.collect(&:to_s).include? 'test2@test.com'
    assert mail['to'].addresses.collect(&:to_s).include? 'etablissement@email.com'
    assert mail['to'].addresses.collect(&:to_s).include? 'contact@dossiersco.beta.gouv.fr'
    assert mail['reply_to'].addresses.collect(&:to_s).include? 'etablissement@email.com'
    assert mail['reply_to'].addresses.collect(&:to_s).include? 'contact@dossiersco.beta.gouv.fr'
    assert_equal 'Réinscription de votre enfant au collège', mail['subject'].to_s
    part = mail.html_part || mail.text_part || mail
    assert part.body.decoded.include? "Tillion"
    assert part.body.decoded.include? "Emile"
  end

  def test_trace_messages_envoyes
    assert_equal 0, Message.count
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/contacter_une_famille', identifiant: '6', message: 'Message de test'

    eleve = Eleve.find_by(identifiant: "6")
    dossier = eleve.dossier_eleve

    assert_equal 1, Message.count
    message = Message.first
    assert_equal "mail", message.categorie
    assert_equal dossier.id, message.dossier_eleve_id
    assert_equal "envoyé", message.etat
    assert_equal "", message.resultat
    assert message.contenu.include? "Tillion"
  end

  def test_trace_sms_envoyes
    assert_equal 0, Message.count

    eleve = Eleve.find_by(identifiant: "6")
    dossier = eleve.dossier_eleve
    dossier.relance_sms

    assert_equal 1, Message.count
    message = Message.first
    message.envoyer

    message = Message.first
    assert_equal "sms", message.categorie
    assert_equal dossier.id, message.dossier_eleve_id
    assert_equal "erreur", message.etat
    assert message.contenu.include? "Tillion"
  end

  def test_envoi_un_mail_quand_un_agent_valide_un_dossier
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/valider_inscription', identifiant: '4'

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

  def assert_file(chemin_du_fichier)
    assert File.file? chemin_du_fichier
    File.delete(chemin_du_fichier)
  end

  def assert_attr(valeur_attendue, selecteur_css, doc)
    valeur_trouvee = doc.css(selecteur_css).attr('value') ? # c'est un input ?
        doc.css(selecteur_css).attr('value').text # oui
      : doc.css(selecteur_css).text # non, on suppose un textarea
    assert_equal valeur_attendue, valeur_trouvee
  end

  def test_affichage_d_options_ogligatoires_a_choisir
    post '/identification', identifiant: '6', date_naiss: '1970-01-01'
    eleve = Eleve.find_by(identifiant: '6')
    montee = Montee.create

    anglais = Option.create(nom: 'anglais', groupe: 'LV1', modalite: 'obligatoire')
    allemand = Option.create(nom: 'allemand', groupe: 'LV1', modalite: 'obligatoire')
    anglais_d = Demandabilite.create montee_id: montee.id, option_id: anglais.id
    allemand_d = Demandabilite.create montee_id: montee.id, option_id: allemand.id
    montee.demandabilite << anglais_d
    montee.demandabilite << allemand_d
    eleve.montee = montee
    eleve.save

    resultat = eleve.genere_demandes_possibles[0]

    assert_equal 'LV1', resultat[:name]
    assert_equal 'radio', resultat[:type]
    assert resultat[:options].include? 'anglais'
    assert resultat[:options].include? 'allemand'

    assert_equal 0, eleve.demande.count

    post '/eleve', LV1: 'allemand'
    eleve = Eleve.find_by(identifiant: '6')
    assert_equal 1, eleve.demande.count
    assert_equal 'allemand', eleve.demande.first.option.nom

    post '/eleve', LV1: 'anglais'
    eleve = Eleve.find_by(identifiant: '6')
    assert_equal 1, eleve.demande.count
    assert_equal 'anglais', eleve.demande.first.option.nom

    assert_equal 'anglais', eleve.genere_demandes_possibles[0][:checked]
  end

  def test_affichage_d_options_facultatives_a_choisir
    post '/identification', identifiant: '6', date_naiss: '1970-01-01'
    eleve = Eleve.find_by(identifiant: '6')
    montee = Montee.create

    latin = Option.create(nom: 'latin', groupe: 'LCA', modalite: 'facultative')
    grec = Option.create(nom: 'grec', groupe: 'LCA', modalite: 'facultative')
    latin_d = Demandabilite.create montee_id: montee.id, option_id: latin.id
    grec_d = Demandabilite.create montee_id: montee.id, option_id: grec.id
    montee.demandabilite << latin_d
    montee.demandabilite << grec_d
    eleve.montee = montee
    eleve.save

    resultat = eleve.genere_demandes_possibles

    assert_equal 'LCA', resultat[0][:label]
    assert_equal 'LCA', resultat[1][:label]
    assert_equal 'check', resultat[0][:type]
    assert_equal 'check', resultat[1][:type]
    assert resultat[0][:name].include? 'latin'
    assert resultat[1][:name].include? 'grec'

    post '/eleve', grec_present: 'true', grec: 'true'
    eleve = Eleve.find_by(identifiant: '6')
    assert_equal 1, eleve.demande.count
    assert_equal 'grec', eleve.demande.first.option.nom
  end

  def test_une_option_facultative_pas_encore_demandee
    post '/identification', identifiant: '6', date_naiss: '1970-01-01'
    eleve = Eleve.find_by(identifiant: '6')
    montee = Montee.create

    grec = Option.create(nom: 'grec', groupe: 'LCA', modalite: 'facultative')
    grec_d = Demandabilite.create montee_id: montee.id, option_id: grec.id
    montee.demandabilite << grec_d
    eleve.montee = montee
    eleve.save

    resultat = eleve.genere_demandes_possibles

    assert_equal 'LCA', resultat[0][:label]
    assert_equal 'check', resultat[0][:type]
    assert_equal false, resultat[0][:condition]
    assert resultat[0][:name].include? 'grec'

    post '/eleve', grec_present: 'true', grec: 'true'
    eleve = Eleve.find_by(identifiant: '6')
    assert_equal 1, eleve.demande.count
    assert_equal 'grec', eleve.demande.first.option.nom
  end

  def test_une_option_facultative_demandee
    post '/identification', identifiant: '6', date_naiss: '1970-01-01'
    eleve = Eleve.find_by(identifiant: '6')
    montee = Montee.create

    grec = Option.create(nom: 'grec', groupe: 'LCA', modalite: 'facultative')
    grec_d = Demandabilite.create montee_id: montee.id, option_id: grec.id
    montee.demandabilite << grec_d
    eleve.montee = montee
    eleve.demande << Demande.create(eleve: eleve, option: grec)
    eleve.save

    resultat = eleve.genere_demandes_possibles

    assert_equal 'LCA', resultat[0][:label]
    assert_equal 'check', resultat[0][:type]
    assert_equal true, resultat[0][:condition]
    assert resultat[0][:name].include?('grec')

    post '/eleve', grec_present: 'true', grec: 'true'
    eleve = Eleve.find_by(identifiant: '6')
    assert_equal 1, eleve.demande.count
    assert_equal 'grec', eleve.demande.first.option.nom

    resultat = eleve.genere_demandes_possibles
    assert_equal true, resultat[0][:condition]

    post '/eleve', grec_present: 'true'
    eleve = Eleve.find_by(identifiant: '6')
    assert_equal 0, eleve.demande.count

    resultat = eleve.genere_demandes_possibles
    assert_equal false, resultat[0][:condition]
  end

  def test_affichage_obligatoire_sans_choix
    post '/identification', identifiant: '5', date_naiss: '1970-01-01'
    eleve = Eleve.find_by(identifiant: '5')

    get '/eleve'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "latin", doc.css("body > main > div.col-sm-12 > form > div:nth-child(13) > div").text.strip
    assert_equal "grec", doc.css("body > main > div.col-sm-12 > form > div:nth-child(14) > div").text.strip
  end

  def test_afficher_option_a_choisir_que_quand_choix_possible
    montee = Montee.create
    e = Eleve.create!(identifiant: 'XXX', date_naiss: '1970-01-01', montee: montee)
    dossier_eleve = DossierEleve.create!(eleve_id: e.id, etablissement_id: Etablissement.first.id)
    post '/identification', identifiant: 'XXX', date_naiss: '1970-01-01'

    get '/eleve'

    assert ! last_response.body.include?("Options choisies précédemment")
    assert ! last_response.body.include?("Vos options pour l'année prochaine")
  end

  def test_affiche_option_obligatoire_nouvelle_pour_cette_montee
    montee = Montee.create
    eleve = Eleve.create!(identifiant: 'XXX', date_naiss: '1970-01-01', montee: montee)
    dossier_eleve = DossierEleve.create!(eleve_id: eleve.id, etablissement_id: Etablissement.first.id)

    grec_obligatoire = Option.create(nom: 'grec', groupe: 'LCA', modalite: 'obligatoire')
    grec_obligatoire_d = Demandabilite.create montee_id: montee.id, option_id: grec_obligatoire.id
    montee.demandabilite << grec_obligatoire_d

    resultat = eleve.genere_demandes_possibles

    assert_equal "LCA", resultat[0][:label]
    assert_equal 'grec', resultat[0][:name]
    assert_equal 'hidden', resultat[0][:type]
  end

  def test_affiche_option_abandonnable
    eleve = Eleve.create!(identifiant: 'XXX', date_naiss: '1970-01-01')
    dossier_eleve = DossierEleve.create!(eleve_id: eleve.id, etablissement_id: Etablissement.first.id)
    montee = Montee.create
    latin = Option.create(nom: 'latin', groupe: 'LCA', modalite: 'facultative')
    latin_d = Abandonnabilite.create montee_id: montee.id, option_id: latin.id
    eleve.option << latin
    montee.abandonnabilite << latin_d
    eleve.update(montee: montee)

    post '/identification', identifiant: 'XXX', date_naiss: '1970-01-01'
    get '/eleve'

    resultat = eleve.genere_abandons_possibles

    assert_equal "Poursuivre l'option", resultat[0][:label]
    assert_equal 'latin', resultat[0][:name]
    assert_equal 'check', resultat[0][:type]

    # Si la checkbox n'est pas cochée le navigateur ne transmet pas la valeur
    post '/eleve', latin_present: true
    eleve = Eleve.find_by(identifiant: 'XXX')
    assert_equal 1, eleve.abandon.count
    assert_equal 'latin', eleve.abandon.first.option.nom

    resultat = eleve.genere_abandons_possibles
    assert_equal "Poursuivre l'option", resultat[0][:label]
    assert_equal false, resultat[0][:condition]

    post '/eleve', latin_present: true, latin: true
    eleve = Eleve.find_by(identifiant: 'XXX')
    assert_equal 0, eleve.abandon.count

    resultat = eleve.genere_abandons_possibles
    assert_equal "Poursuivre l'option", resultat[0][:label]
    assert_equal true, resultat[0][:condition]
  end

  def test_affiche_404
    # Sans identification, on est redirigé vers l'identification
    get '/unepagequinexistepas'
    assert last_response.redirect?

    post '/identification', identifiant: '5', date_naiss: '1970-01-01'
    get '/unepagequinexistepas'
    assert last_response.body.include? "une page qui n'existe pas"
  end

  def test_erreur_interne
    Sinatra::Application::set :environment, 'production'
    get '/unepagequileveuneexception'
    assert last_response.body.include? "une erreur technique"
    Sinatra::Application::set :environment, 'development'
  end

  def test_stats
    get '/stats'
    doc = Nokogiri::HTML(last_response.body)
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
    assert_equal "width: 100.0%;", doc.css(pas_connecte).first.attr("style")
  end

  def test_meme_adresse
    r = RespLegal.new adresse: '42 rue', code_postal: '75020', ville: 'Paris'
    assert       r.meme_adresse(r)
    assert       r.meme_adresse(RespLegal.new adresse: r.adresse, code_postal: r.code_postal, ville: r.ville)
    assert_false r.meme_adresse(nil)
    assert_false r.meme_adresse(RespLegal.new adresse: '30',      code_postal: r.code_postal, ville: r.ville)
    assert_false r.meme_adresse(RespLegal.new adresse: r.adresse, code_postal: '59001',       ville: r.ville)
    assert_false r.meme_adresse(RespLegal.new adresse: r.adresse, code_postal: r.code_postal, ville: 'Lyon')
  end

  def test_page_eleve_agent_affiche_changement_adresse
    resp_legal_1 = Eleve.find_by(identifiant: '2').dossier_eleve.resp_legal_1
    resp_legal_1.update adresse: 'Nouvelle adresse'

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    get '/agent/eleve/2'

    doc = Nokogiri::HTML(last_response.body)
    assert_not_nil doc.css("div#ancienne_adresse").first
  end

  def test_page_eleve_agent_affiche_adresse_sans_changement
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    get '/agent/eleve/2'

    doc = Nokogiri::HTML(last_response.body)
    assert_nil doc.css("div#ancienne_adresse").first
  end

  def test_affiche_pas_resp_legal_2_si_absent_de_siecle
    e = Eleve.create! identifiant: 'XXX', date_naiss: '1915-12-19'
    dossier_eleve = DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first
    RespLegal.create! dossier_eleve_id: dossier_eleve.id, email: 'test@test.com', priorite: 1

    post '/identification', identifiant: 'XXX', date_naiss: '1915-12-19'
    get '/famille'

    doc = Nokogiri::HTML(last_response.body)
    assert_nil doc.css("div#resp_legal_2").first
  end

  def test_detection_adresses_identiques
    rl = RespLegal.create(
        adresse_ant:"4 IMPASSE MORLET",
        ville_ant: "PARIS",
        code_postal_ant:"75011",
        adresse:"4 impasse Morlet\n",
        ville:"  Paris\r",
        code_postal: "75 011")
    assert rl.adresse_inchangee
  end

  def test_detection_adresses_identiques_cas_degenere
    assert RespLegal.new.adresse_inchangee
  end

  def test_un_agent_voit_un_commentaire_parent_dans_vue_eleve
    e = Eleve.create! identifiant: 'XXX'
    d= DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first, commentaire: "Commentaire de test"
    RespLegal.create! dossier_eleve_id: d.id,
      tel_principal: '0101010101', tel_secondaire: '0606060606', email: 'test@test.com', priorite: 1

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get "/agent/eleve/XXX"

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "#{d.satisfaction} : Commentaire de test", doc.css("div#commentaire").first.text
  end
end
