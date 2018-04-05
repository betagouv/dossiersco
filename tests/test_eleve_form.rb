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
    assert last_response.body.include? 'Le conseil de classe'
  end

  def test_entree_succes_firefox_52_0_1_eleve_1
    post '/identification', identifiant: '1', date_naiss: '19/11/1995'
    follow_redirect!
    assert last_response.body.include? 'Le conseil de classe'
  end


  def test_entree_succes_date_avec_espaces_eleve_1
    post '/identification', identifiant: '1', date_naiss: '19 11 1995'
    follow_redirect!
    assert last_response.body.include? 'Le conseil de classe'
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

  def test_passage_de_eleve_vers_scolarite
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    post '/eleve'
    follow_redirect!
    assert last_response.body.include? 'Enseignement obligatoire'
  end

  # def test_accueil_et_inscription
  #   post '/identification', identifiant: '2', date_naiss: '1915-12-19'
  #   follow_redirect!
  #   assert last_response.body.include? 'son inscription'
  # end

  def test_accueil_et_réinscription
    post '/identification', identifiant: '1', date_naiss: '1995-11-19'
    follow_redirect!
    assert last_response.body.include? 'réinscription'
  end

  def test_persistence_des_choix_enseignements
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    post '/scolarite', lv2: 'Espagnol'
    get '/scolarite'
    assert last_response.body.gsub(/\s/,'').include? '<input name="lv2" value="Espagnol" type="radio" class="form-check-input" checked>'.gsub(/\s/,'')
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

    assert_equal 'Tutrice', doc.css('#lien_de_parente_rl1 option[@selected="selected"]').children.text
    assert_equal 'Philippe', doc.css('#prenom_rl1').attr('value').text
    assert_equal 'Blayo', doc.css('#nom_rl1').attr('value').text
    assert_equal '20 bd Segur', doc.css('#adresse_rl1').attr('value').text
    assert_equal '75007', doc.css('#code_postal_rl1').attr('value').text
    assert_equal 'Paris', doc.css('#ville_rl1').attr('value').text
    assert_equal '0612345678', doc.css('#tel_principal_rl1').attr('value').text
    assert_equal '0112345678', doc.css('#tel_secondaire_rl1').attr('value').text
    assert_equal 'test@gmail.com', doc.css('#email_rl1').attr('value').text
    assert_equal 'Retraite', doc.css('#situation_emploi_rl1 option[@selected="selected"]').children.text
    assert_equal 'Cadre', doc.css('#profession_rl1 option[@selected="selected"]').children.text
    assert_equal '2', doc.css('#enfants_a_charge_secondaire_rl1').attr('value').text
    assert_equal '3', doc.css('#enfants_a_charge_rl1').attr('value').text
    assert_equal 'checked', doc.css('#communique_info_parents_eleves_rl1_true').attr('checked').text
  end


  def test_persistence_du_resp_legal_2
    doc = soumet_formulaire  '/famille',
                             lien_de_parente_rl2: "Tutrice", prenom_rl2: "Philippe" , nom_rl2: "Blayo",
                             adresse_rl2: "20 bd Segur",code_postal_rl2: "75007", ville_rl2: "Paris",
                             tel_principal_rl2: "0612345678", tel_secondaire_rl2: "0112345678",
                             email_rl2: "test@gmail.com", situation_emploi_rl2: "Retraite", profession_rl2: "Cadre",
                             communique_info_parents_eleves_rl2: 'true'

    assert_equal 'Tutrice', doc.css('#lien_de_parente_rl2 option[@selected="selected"]').children.text
    assert_equal 'Philippe', doc.css('#prenom_rl2').attr('value').text
    assert_equal 'Blayo', doc.css('#nom_rl2').attr('value').text
    assert_equal '20 bd Segur', doc.css('#adresse_rl2').attr('value').text
    assert_equal '75007', doc.css('#code_postal_rl2').attr('value').text
    assert_equal 'Paris', doc.css('#ville_rl2').attr('value').text
    assert_equal '0612345678', doc.css('#tel_principal_rl2').attr('value').text
    assert_equal '0112345678', doc.css('#tel_secondaire_rl2').attr('value').text
    assert_equal 'test@gmail.com', doc.css('#email_rl2').attr('value').text
    assert_equal 'Retraite', doc.css('#situation_emploi_rl2 option[@selected="selected"]').children.text
    assert_equal 'Cadre', doc.css('#profession_rl2 option[@selected="selected"]').children.text
    assert_equal 'checked', doc.css('#communique_info_parents_eleves_rl2_true').attr('checked').text
  end


  def test_persistence_du_contact_urg
    doc = soumet_formulaire '/famille',
                            lien_avec_eleve_urg: "Tuteur", prenom_urg: "Philippe" , nom_urg: "Blayo",
                            adresse_urg: "20 bd Segur",code_postal_urg: "75007", ville_urg: "Paris",
                            tel_principal_urg: "0612345678", tel_secondaire_urg: "0112345678"

    assert_equal 'Tuteur', doc.css('#lien_avec_eleve_urg').attr('value').text
    assert_equal 'Philippe', doc.css('#prenom_urg').attr('value').text
    assert_equal 'Blayo', doc.css('#nom_urg').attr('value').text
    assert_equal '20 bd Segur', doc.css('#adresse_urg').attr('value').text
    assert_equal '75007', doc.css('#code_postal_urg').attr('value').text
    assert_equal 'Paris', doc.css('#ville_urg').attr('value').text
    assert_equal '0612345678', doc.css('#tel_principal_urg').attr('value').text
    assert_equal '0112345678', doc.css('#tel_secondaire_urg').attr('value').text
  end


  def test_piece_jointe_invite_a_prendre_en_photo
    post '/identification', identifiant: '2', date_naiss: '1915-12-19'
    get '/pieces_a_joindre'
    doc = Nokogiri::HTML(last_response.body)

    assert_equal 'Parcourir / Prendre en photo', doc.css('label[for=photo_identite]').text
    assert_equal 'Parcourir / Prendre en photo', doc.css('label[for=assurance_scolaire]').text
    assert_equal 'Parcourir / Prendre en photo', doc.css('label[for=jugement_garde_enfant]').text
  end


=begin
  def test_joindre_photo_identite
    piece_a_joindre = Tempfile.new('fichier_temporaire')

    doc = soumet_formulaire '/pieces_a_joindre', photo_identite: {"tempfile": piece_a_joindre.path}

    assert_equal 'Modifier', doc.css('label[for=photo_identite]').text
    assert_file "public/uploads/#{File.basename(piece_a_joindre.path)}"
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
=end


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
    assert last_response.body.include? 'Arago'
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
    assert_equal '4', affichage_total_dossiers
  end

  def test_singularize_dossier_eleve
    assert_equal 'dossier_eleves', 'dossier_eleves'.singularize
  end

  def test_importe_eleve_fichier_siecle
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/import_siecle', name: 'import_siecle', filename: {tempfile: 'tests/test_import_siecle.xls'}

    eleve = Eleve.find_by(nom: 'NOM_TEST')
    eleve2 = Eleve.find_by(nom: 'NOM2_TEST')

    assert eleve.prenom == 'Prenom_test'
    assert eleve.identifiant == '080788316HE'
    assert eleve.pays_naiss == 'FRANCE'
    assert eleve.ville_naiss == 'PARIS 12E  ARRONDISSEMENT'
    assert eleve2.prenom == 'Prenom2_test'
    assert eleve2.identifiant == '080788306HE'
    assert eleve2.pays_naiss == 'CONGO'
    assert eleve2.ville_naiss == 'Brazaville'
  end

  def test_importe_resp_legaux_fichier_siecle
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/import_siecle', name: 'import_siecle', filename: {tempfile: 'tests/test_import_siecle.xls'}

    resp_legaux = RespLegal.where(nom: 'PUYDEBOIS')

    assert resp_legaux.size == 2

  end

end
