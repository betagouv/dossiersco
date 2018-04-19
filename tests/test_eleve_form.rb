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

  def app
    Sinatra::Application
  end

  def setup
    init
  end

  def test_accueil
    get '/'
    assert last_response.body.include? 'Inscription'
  end

  def test_entree_succes_eleve_1
    post '/identification', identifiant: '1', date_naiss: '1995-11-19'
    follow_redirect!
    assert last_response.body.include? 'Pour inscrire votre enfant'
  end

  def test_entree_succes_firefox_52_0_1_eleve_1
    post '/identification', identifiant: '1', date_naiss: '19/11/1995'
    follow_redirect!
    assert last_response.body.include? 'Pour inscrire votre enfant'
  end


  def test_entree_succes_date_avec_espaces_eleve_1
    post '/identification', identifiant: '1', date_naiss: '19 11 1995'
    follow_redirect!
    assert last_response.body.include? 'Pour inscrire votre enfant'
  end

  def test_entree_mauvais_identifiant
    post '/identification', identifiant: '3', date_naiss: '1995-11-19'
    follow_redirect!
    assert last_response.body.include? 'Nous ne connaissons aucun élève correspondant à ces informations'
  end

  def test_nom_college_accueil
    post '/identification', identifiant: '1', date_naiss: '1995-11-19'
    follow_redirect!
    doc = Nokogiri::HTML(last_response.body)
    assert_equal 'College Jean-Francois Oeben', doc.xpath("//div//h1/text()").to_s
    assert_equal 'College Jean-Francois Oeben', doc.xpath("//strong[@id='etablissement']/text()").to_s.strip
    assert_equal '20 Mai 2018', doc.xpath("//strong[@id='date-limite']/text()").to_s
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
     "<input class='form-check-input' type='checkbox' name='Espagnol' value='true' id='Espagnol' checked >".gsub(/\s/,''))
    assert last_response.body.gsub(/\s/,'').include?(
     "<input class='form-check-input' type='checkbox' name='Latin' value='true' id='Latin' checked >".gsub(/\s/,''))
  end

  def test_affiche_2ème_et_3ème_prénoms_en_4ème_pour_brevet_des_collèges
    post '/identification', identifiant: '4', date_naiss: '1970-01-01'
    get '/eleve'
    assert last_response.body.include? '(Deuxième prénom)'
    assert last_response.body.include? '(Troisième prénom)'
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
    assert last_response.body.include? '(Deuxième prénom)'
    assert last_response.body.include? '(Troisième prénom)'
  end

  def test_accueil_et_réinscription
    post '/identification', identifiant: '1', date_naiss: '1995-11-19'
    follow_redirect!
    assert last_response.body.include? 'réinscription'
  end

  def test_dossier_eleve_possede_deux_resp_legaux
    dossier_eleve = DossierEleve.first

    RespLegal.create(dossier_eleve_id: dossier_eleve.id)
    RespLegal.create(dossier_eleve_id: dossier_eleve.id)

    assert dossier_eleve.resp_legal.size == 2
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
                            email_rl1: "test@gmail.com", situation_emploi_rl1: "Retraite", profession_rl1: "Cadre",
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
    assert_equal 'Retraite', doc.css('#situation_emploi_rl1 option[@selected="selected"]').children.text
    assert_equal 'Cadre', doc.css('#profession_rl1 option[@selected="selected"]').children.text
    assert_attr '2', '#enfants_a_charge_secondaire_rl1', doc
    assert_attr '3', '#enfants_a_charge_rl1', doc
    assert_equal 'checked', doc.css('#communique_info_parents_eleves_rl1_true').attr('checked').text
  end


  def test_persistence_du_resp_legal_2
    doc = soumet_formulaire  '/famille',
                             lien_de_parente_rl2: "Tutrice", prenom_rl2: "Philippe" , nom_rl2: "Blayo",
                             adresse_rl2: "20 bd Segur",code_postal_rl2: "75007", ville_rl2: "Paris",
                             tel_principal_rl2: "0612345678", tel_secondaire_rl2: "0112345678",
                             email_rl2: "test@gmail.com", situation_emploi_rl2: "Retraite", profession_rl2: "Cadre",
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
    assert_equal 'Retraite', doc.css('#situation_emploi_rl2 option[@selected="selected"]').children.text
    assert_equal 'Cadre', doc.css('#profession_rl2 option[@selected="selected"]').children.text
    assert_equal 'checked', doc.css('#communique_info_parents_eleves_rl2_true').attr('checked').text
  end


  def test_persistence_du_contact_urg
    doc = soumet_formulaire '/famille',
                            lien_avec_eleve_urg: "Tuteur", prenom_urg: "Philippe" , nom_urg: "Blayo",
                            adresse_urg: "20 bd Segur",code_postal_urg: "75007", ville_urg: "Paris",
                            tel_principal_urg: "0612345678", tel_secondaire_urg: "0112345678"

    assert_attr 'Tuteur', '#lien_avec_eleve_urg', doc
    assert_attr 'Philippe', '#prenom_urg', doc
    assert_attr 'Blayo', '#nom_urg', doc
    assert_attr '20 bd Segur', '#adresse_urg', doc
    assert_attr '75007', '#code_postal_urg', doc
    assert_attr 'Paris', '#ville_urg', doc
    assert_attr '0612345678', '#tel_principal_urg', doc
    assert_attr '0112345678', '#tel_secondaire_urg', doc
  end


  def test_piece_jointe_invite_a_prendre_en_photo
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    get '/pieces_a_joindre'
    doc = Nokogiri::HTML(last_response.body)

    assert_equal 'Parcourir / Prendre en photo', doc.css('label[for=photo_identite]').text
    assert_equal 'Parcourir / Prendre en photo', doc.css('label[for=assurance_scolaire]').text
    assert_equal 'Parcourir / Prendre en photo', doc.css('label[for=jugement_garde_enfant]').text
  end

  def test_joindre_photo_identite
    piece_a_joindre = Tempfile.new('fichier_temporaire')

    doc = soumet_formulaire '/pieces_a_joindre', photo_identite: {"tempfile": piece_a_joindre.path}

    assert_equal 'Modifier', doc.css('label[for=photo_identite]').text
    assert_equal 'Parcourir / Prendre en photo', doc.css('label[for=assurance_scolaire]').text
    assert_file "public/uploads/#{File.basename(piece_a_joindre.path)}"

    expected_url = "/uploads/#{File.basename(piece_a_joindre.path)}"
    assert_equal "background-image: url('#{expected_url}'); height: 200px; max-width: 350px;",
                 doc.css("#image_photo_identite").attr("style").text
    assert doc.css("#fichier_assurance_scolaire img").empty?
    assert doc.css("#fichier_jugement_garde_enfant img").empty?
  end

  def test_joindre_assurance_scolaire
    piece_a_joindre = Tempfile.new('fichier_temporaire')

    doc = soumet_formulaire '/pieces_a_joindre', assurance_scolaire: {"tempfile": piece_a_joindre.path}

    assert_equal 'Modifier', doc.css('label[for=assurance_scolaire]').text
    assert_file "public/uploads/#{File.basename(piece_a_joindre.path)}"
  end

  def test_joindre_jugement_garde_enfant
    piece_a_joindre = Tempfile.new('fichier_temporaire')

    doc = soumet_formulaire '/pieces_a_joindre', jugement_garde_enfant: {"tempfile": piece_a_joindre.path}

    assert_equal 'Modifier', doc.css('label[for=jugement_garde_enfant]').text
    assert_file "public/uploads/#{File.basename(piece_a_joindre.path)}"
  end

  def soumet_formulaire(*arguments_du_post)
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    post *arguments_du_post
    get arguments_du_post[0]
    Nokogiri::HTML(last_response.body)
  end

#   Tests agents

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
         filename: {tempfile: 'tests/test_import_siecle.xls'}

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
  end

  def test_compte_taux_de_portables_dans_siecle
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/import_siecle', name: 'import_siecle', filename: {tempfile: 'tests/test_import_siecle.xls'}
    doc = Nokogiri::HTML(last_response.body)
    assert_match "100% de téléphones portables", doc.css('.message_de_succes').text
    assert_match "50% d'emails", doc.css('.message_de_succes').text
  end

  def test_un_visiteur_anonyme_ne_peut_pas_valider_une_piece_jointe
    dossier_eleve = DossierEleve.first
    etat_préservé = dossier_eleve.etat_photo_identite

    post '/agent/change_etat_fichier', id: dossier_eleve.id, etat: 'validé', nom_fichier: 'etat_photo_identite'

    dossier_eleve_en_base = DossierEleve.find(dossier_eleve.id)
    assert_equal etat_préservé, dossier_eleve_en_base.etat_photo_identite
  end

  def test_un_agent_visualise_un_eleve
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    get '/agent/eleve/2'

    assert last_response.body.include? 'Edith'
    assert last_response.body.include? 'Piaf'
  end

  def test_un_agent_importe_un_eleve
    DossierEleve.destroy_all
    Eleve.destroy_all
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/import_siecle', nom_eleve: 'NOM_TEST', prenom_eleve: 'Prenom_test',
         name: 'import_siecle', filename: {tempfile: 'tests/test_import_siecle.xls'}
    assert_equal 1, Eleve.all.size
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

    post '/agent/options', nom: 'Allemand', niveau_debut: '4ème', obligatoire: true

    post '/identification', identifiant: '5', date_naiss: '1970-01-01'
    get '/eleve'
    assert_match /Allemand/, last_response.body
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

    post '/agent/options', nom: 'Grec', niveau_debut: '3ème', obligatoire: false

    post '/identification', identifiant: '4', date_naiss: '1970-01-01'
    get '/eleve'
    assert_match /Grec/, last_response.body
    assert_match /facultatif/, last_response.body
  end


  def assert_file(chemin_du_fichier)
    assert File.file? chemin_du_fichier
    File.delete(chemin_du_fichier)
  end

  def assert_attr(valeur_attendue, selecteur_css, doc)
    assert_equal valeur_attendue, doc.css(selecteur_css).attr('value').text
  end
end
