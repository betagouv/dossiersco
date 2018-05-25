ENV['RACK_ENV'] = 'test'

require 'nokogiri'
require 'test/unit'
require 'rack/test'
require 'tempfile'

require_relative '../helpers/singulier_francais'

require_relative '../dossiersco_web'
require_relative '../dossiersco_agent'
require_relative '../db/seeds'


class EleveFormTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include MotDePasse

  def app
    Sinatra::Application
  end

  def setup
    init
  end

  def test_normalise_date_naissance
    assert_equal "2018-05-14", normalise("14 05 2018")
    assert_equal "2018-05-14", normalise("14/05/2018")
    assert_equal nil, normalise("foo")
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

  def test_entree_mauvais_identifiant
    post '/identification', identifiant: '3', date_naiss: '1995-11-19'
    follow_redirect!
    assert last_response.body.include? "L'élève a bien comme identifiant 3 et comme date de naissance le 19 novembre 1995 ?"
  end

  def test_entree_mauvaise_date
    post '/identification', identifiant: '3', date_naiss: 'foo'
    follow_redirect!
    assert last_response.body.include? "Nous n'avons pas reconnu la date de naissance de l'élève."
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

  def test_persistence_des_choix_enseignements
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    post '/eleve', Espagnol: true, Latin: true
    get '/eleve'

    assert last_response.body.gsub(/\s/,'').include?(
     '<input name="Langue vivante 2" value="Espagnol" type="radio" class="form-check-input" checked>'.gsub(/\s/,''))
    assert last_response.body.gsub(/\s/,'').include?(
     "<input class='form-check-input' type='checkbox' name='Latin' value='true' id='Latin' checked >".gsub(/\s/,''))
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

    ContactUrgence.create(dossier_eleve_id: dossier_eleve.id, tel_principal: "0123456789")

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
    champs = [:lien_de_parente, :prenom, :nom, :adresse, :code_postal, :ville,
              :tel_principal, :tel_secondaire, :email]

    donnees = {}
    champs.each do |champ|
      ['rl1','rl2'].each do |rl|
        champ_qualifie = "#{champ}_#{rl}"
        selecteur = "\##{champ_qualifie}"
        valeur = doc.css(selecteur).attr('value').text
        donnees[champ_qualifie] = valeur
      end
    end

    # Pas de changement d'adresse
    donnees['tel_principal_rl1'] = "Changement de numéro"
    doc = soumet_formulaire '/famille', donnees
    champs.each do |champ|
      ['rl1','rl2'].each do |rl|
        champ_qualifie = "#{champ}_#{rl}"
        selecteur = "\##{champ_qualifie}"
        assert_attr donnees[champ_qualifie], selecteur, doc
      end
    end

    eleve = Eleve.find_by(identifiant: 2)
    assert !eleve.dossier_eleve.resp_legal.collect(&:changement_adresse).any?

    # Changement d'adresse
    donnees['adresse_rl1'] = "Nouvelle adresse"
    doc = soumet_formulaire '/famille', donnees

    eleve = Eleve.find_by(identifiant: 2)
    assert eleve.dossier_eleve.resp_legal.collect(&:changement_adresse).any?
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
    assert_equal "background-image: url('/images/reglement_dp_small.png'); height: 200px; max-width: 350px;",
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

    assert_match /Famille .*: Responsable légal 1/, last_response.body
  end


  def soumet_formulaire(*arguments_du_post)
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    post *arguments_du_post
    get arguments_du_post[0]
    Nokogiri::HTML(last_response.body)
  end

##############################################################################
#   Tests agents
##############################################################################

  def test_entree_succes_agent
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    follow_redirect!
    assert last_response.body.include? 'Collège Germaine Tillion'
  end

  def test_entree_mauvais_identifiant_agent
    post '/agent', identifiant: 'pierre', mot_de_passe: 'pierre'
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
    etablissement = Etablissement.find_by(nom: 'Collège Germaine Tillion')
    tache_import = TacheImport.create(url: 'tests/test_import_siecle.xls', statut: 'en_attente',
      etablissement_id: etablissement.id)
    get '/api/traiter_imports'
    assert_equal 200, last_response.status

    eleve = Eleve.find_by(nom: 'NOM_TEST')
    eleve2 = Eleve.find_by(nom: 'NOM2_TEST')

    assert_equal 'Masculin', eleve.sexe
    assert_equal 'Prenom_test', eleve.prenom
    assert_equal 'Prenom_test_2', eleve.prenom_2
    assert_equal 'Prenom_test_3', eleve.prenom_3
    assert_equal '080788316HE', eleve.identifiant
    assert_equal 'FRANCE', eleve.pays_naiss
    assert_equal 'PARIS 12E  ARRONDISSEMENT', eleve.ville_naiss
    assert_equal '4ème 5 SEGPA', eleve.classe_ant
    assert_equal 'Collège Germaine Tillion', eleve.dossier_eleve.etablissement.nom
    assert_equal 'Prenom2_test', eleve2.prenom
    assert_equal '080788306HE', eleve2.identifiant
    assert_equal 'CONGO', eleve2.pays_naiss
    assert_equal 'Brazaville', eleve2.ville_naiss
    assert_equal '4EME HORAIRES AMENAGES MUSIQUE', eleve2.niveau_classe_ant
    assert_nil eleve2.classe_ant

    tache_import = TacheImport.find_by(statut: 'terminée')
    assert_equal(tache_import.url, 'tests/test_import_siecle.xls')
  end

  def test_import_des_options
    etablissement = Etablissement.find_by(nom: 'College Jean-Francois Oeben')
    lignes_siecle = [
      {11 => '1', 9 => "18/05/1991", 37 => "AGL1", 38 => "ANGLAIS LV1", 39 => "O", 33 => '4'},
      {11 => '2', 9 => "18/05/1991", 37 => "ESP2", 38 => "ESPAGNOL LV2", 39 => "F", 33 => '4'},
      {11 => '3', 9 => "18/05/1991", 37 => "AGL1", 38 => "ANGLAIS LV1", 39 => "O", 33 => '4'}
    ]

    lignes_siecle.each { |ligne| import_ligne etablissement.id, ligne }

    options = etablissement.option

    assert_equal 2, options.count

    eleve1 = Eleve.find_by(identifiant: "1")
    nom_option_eleve1 = eleve1.option.collect(&:nom)
    assert nom_option_eleve1.include? 'Anglais'
    noms = options.collect(&:nom)
    assert noms.include? 'Anglais'
    assert noms.include? 'Espagnol'
  end

  def test_creer_des_options
    Option.destroy_all
    etablissement_id = Etablissement.find_by(nom: 'College Jean-Francois Oeben').id
    colonnes_siecle = [
      {id: etablissement_id, libelle: 'ANGLAIS LV1', cle_gestion: 'AGL1', code: 'O',
        nom_attendu: 'Anglais', groupe_attendu: 'Langue vivante 1', obligatoire: true},
      {id: etablissement_id, libelle: 'ESPAGNOL LV2', cle_gestion: 'ESP2', code: 'O',
        nom_attendu: 'Espagnol', groupe_attendu: 'Langue vivante 2', obligatoire: true},
      {id: etablissement_id, libelle: 'ESPAGNOL LV2 ND', cle_gestion: 'ES2ND', code: 'O',
        nom_attendu: 'Espagnol non débutant', groupe_attendu: 'Langue vivante 2', obligatoire: true},
      {id: etablissement_id, libelle: 'ALLEMAND LV2', cle_gestion: 'ALL2', code: 'O',
        nom_attendu: 'Allemand', groupe_attendu: 'Langue vivante 2', obligatoire: true},
      {id: etablissement_id, libelle: 'ALLEMAND LV2 ND', cle_gestion: 'AL2ND', code: 'O',
        nom_attendu: 'Allemand non débutant', groupe_attendu: 'Langue vivante 2', obligatoire: true},
      {id: etablissement_id, libelle: 'LCA LATIN', cle_gestion: 'LCALA', code: 'F',
        nom_attendu: 'Latin', groupe_attendu: "Langues et cultures de l'antiquité", obligatoire: false},
      {id: etablissement_id, libelle: 'LCA GREC', cle_gestion: 'LCAGR', code: 'F',
        nom_attendu: 'Grec', groupe_attendu: "Langues et cultures de l'antiquité", obligatoire: false},
    ]

    colonnes_siecle.each do |colonne|
      creer_option colonne[:id], colonne[:libelle], colonne[:cle_gestion], colonne[:code]

      option = Option.where(nom: colonne[:nom_attendu], groupe: colonne[:groupe_attendu], obligatoire: colonne[:obligatoire])
      assert_equal 1, option.count
    end
  end

  def test_compte_taux_de_portables_dans_siecle
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/import_siecle', name: 'import_siecle', filename: Rack::Test::UploadedFile.new("tests/test_import_siecle.xls")
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
         name: 'import_siecle',
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
    post '/administration', demi_pensionnaire: true, autorise_sortie: true,
      renseignements_medicaux: true, autorise_photo_de_classe: false
    get '/administration'

    assert last_response.body.gsub(/\s/,'').include? "id='demi_pensionnaire' checked".gsub(/\s/,'')
    assert last_response.body.gsub(/\s/,'').include? "id='autorise_sortie' checked".gsub(/\s/,'')
    assert last_response.body.gsub(/\s/,'').include? "id='renseignements_medicaux' checked".gsub(/\s/,'')
    assert last_response.body.gsub(/\s/,'').include? "id='autorise_photo_de_classe' checked".gsub(/\s/,'')
  end

  def test_un_agent_ajoute_une_nouvelle_option_obligatoire
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    post '/agent/options', nom: 'Italien', niveau_debut: '4ème', obligatoire: true

    post '/identification', identifiant: '5', date_naiss: '1970-01-01'
    get '/eleve'
    assert_match /Italien/, last_response.body
    assert_match /obligatoire/, last_response.body
  end

  def test_un_agent_ajoute_deux_fois_la_meme_option
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    post '/agent/options', nom: 'Latin', niveau_debut: '4ème'
    post '/agent/options', nom: 'latin', niveau_debut: '4ème'

    assert_match /latin existe déjà/, last_response.body
  end

  def test_un_agent_ajoute_une_nouvelle_option_facultative
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    post '/agent/options', nom: 'Musique', niveau_debut: '3ème', obligatoire: false

    post '/identification', identifiant: '4', date_naiss: '1970-01-01'
    get '/eleve'
    assert_match /Musique/, last_response.body
    assert_match /facultatif/, last_response.body
  end

  def test_un_agent_supprime_option
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/options', nom: 'Musique', niveau_debut: '3ème'
    get '/agent/options'
    assert_match /Musique/, last_response.body

    post '/agent/supprime_option', option_id: Option.last.id

    get '/agent/options'
    assert_no_match /Musique/, last_response.body
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

  def test_affiche_changement_adresse_liste_eleves
    # Si on a un changement d'adresse
    eleve = Eleve.find_by(identifiant: 2)
    resp_legal = eleve.dossier_eleve.resp_legal.first
    resp_legal.changement_adresse = true
    resp_legal.save

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/liste_des_eleves'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "✓", doc.css("tbody > tr:nth-child(1) > td:nth-child(5)").text.strip
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
    get '/confirmation'
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

  def assert_file(chemin_du_fichier)
    assert File.file? chemin_du_fichier
    File.delete(chemin_du_fichier)
  end

  def assert_attr(valeur_attendue, selecteur_css, doc)
    assert_equal valeur_attendue, doc.css(selecteur_css).attr('value').text
  end
end
