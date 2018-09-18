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

  def test_normalise_INE
    assert_equal "070803070AJ", normalise_alphanum(" %! 070803070aj _+ ")
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
    post '/identification', identifiant: '1 ', annee: '1995', mois: '11', jour: '19'
    follow_redirect!
    assert last_response.body.include? 'Pour réinscrire votre enfant'
  end

  def test_entree_mauvaise_date
    post '/identification', identifiant: '3', annee: '1995', mois: '11', jour: '19'
    follow_redirect!
    assert last_response.body.include? "Nous n'avons pas reconnu ces identifiants, merci de les vérifier."
  end

  def test_entree_mauvais_identifiant_et_date
    post '/identification', identifiant: 'toto', annee: '1998', mois: '11', jour: '19'
    follow_redirect!
    assert last_response.body.include? "Nous n'avons pas reconnu ces identifiants, merci de les vérifier."
  end

  def test_nom_college_accueil
    post '/identification', identifiant: '1', annee: '1995', mois: '11', jour: '19'
    follow_redirect!
    doc = Nokogiri::HTML(last_response.body)
    assert_equal 'College Jean-Francois Oeben', doc.xpath("//div//h1/text()").to_s
    assert_equal 'College Jean-Francois Oeben.', doc.xpath("//strong[@id='etablissement']/text()").to_s.strip
    assert_equal 'samedi 3 juin 2018', doc.xpath("//strong[@id='date-limite']/text()").to_s
  end

  def test_modification_lieu_naiss_eleve
    post '/identification', identifiant: '2', annee: '1915', mois: '12', jour: '19'
    post '/eleve', ville_naiss: 'Beziers', prenom: 'Edith'
    get '/eleve'
    assert last_response.body.include? 'Edith'
    assert last_response.body.include? 'Beziers'
  end

  def test_modifie_une_information_de_eleve_preserve_les_autres_informations
    post '/identification', identifiant: '2', annee: '1915', mois: '12', jour: '19'
    post '/eleve', prenom: 'Edith'
    get '/eleve'
    assert last_response.body.include? 'Piaf'
  end

  def test_affiche_2ème_et_3ème_prénoms_en_4ème_pour_brevet_des_collèges
    post '/identification', identifiant: '4', annee: '1970', mois: '01', jour: '01'
    get '/eleve'
    assert last_response.body.include? 'Deuxième prénom'
    assert last_response.body.include? 'Troisième prénom'
  end

  def test_n_affiche_pas_2ème_et_3ème_prénoms_en_5ème
    post '/identification', identifiant: '5', annee: '1970', mois: '01', jour: '01'
    get '/eleve'
    assert_no_match /Deuxième prénom/, last_response.body
    assert_no_match /Troisième prénom/, last_response.body
  end

  def test_n_affiche_pas_2ème_et_3ème_prénoms_en_6ème
    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'
    get '/eleve'
    assert_no_match /Deuxième prénom/, last_response.body
    assert_no_match /Troisième prénom/, last_response.body
  end

  def test_affiche_2ème_et_3ème_prénoms_en_CM2
    post '/identification', identifiant: '1', annee: '1995', mois: '11', jour: '19'
    get '/eleve'
    assert last_response.body.include? 'Deuxième prénom'
    assert last_response.body.include? 'Troisième prénom'
  end

  def test_accueil_et_inscription
    post '/identification', identifiant: '1', annee: '1995', mois: '11', jour: '19'
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
                            lien_de_parente_rl1: "TUTEUR", prenom_rl1: "Philippe", nom_rl1: "Blayo",
                            adresse_rl1: "20 bd Segur", code_postal_rl1: "75007", ville_rl1: "Paris",
                            tel_principal_rl1: "0612345678", tel_secondaire_rl1: "0112345678",
                            email_rl1: "test@gmail.com", situation_emploi_rl1: "Pré retraité, retraité ou retiré",
                            profession_rl1: "Retraité cadre, profession interm édiaire",
                            enfants_a_charge_secondaire_rl1: 2, enfants_a_charge_rl1: 3,
                            communique_info_parents_eleves_rl1: 'true'

    assert_equal 'TUTEUR', doc.css('#lien_de_parente_rl1 option[@selected="selected"]').children.text
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
    assert_equal 'checked', doc.css('#communique_info_parents_eleves_rl1').attr('checked').text
  end

  def test_persistence_du_resp_legal_2
    doc = soumet_formulaire  '/famille',
                             lien_de_parente_rl2: "MERE", prenom_rl2: "Philippe" , nom_rl2: "Blayo",
                             adresse_rl2: "20 bd Segur",code_postal_rl2: "75007", ville_rl2: "Paris",
                             tel_principal_rl2: "0612345678", tel_secondaire_rl2: "0112345678",
                             email_rl2: "test@gmail.com", situation_emploi_rl2: "Pré retraité, retraité ou retiré",
                             profession_rl2: "Retraité cadre, profession interm édiaire",
                             communique_info_parents_eleves_rl2: 'true'

    assert_equal 'MERE', doc.css('#lien_de_parente_rl2 option[@selected="selected"]').children.text
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
    assert_equal 'checked', doc.css('#communique_info_parents_eleves_rl2').attr('checked').text
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
    post '/identification', identifiant: '2', annee: '1915', mois: '12', jour: '19'
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
    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'
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
    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'
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
    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'
    post '/eleve', Espagnol: true, Latin: true

    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'
    follow_redirect!

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "Famille : Responsable légal 1", doc.css("body > main > div.col-12 > h2").text
  end

  def test_envoyer_un_mail_quand_la_demande_dinscription_est_valide
    post '/identification', identifiant: '4', annee: '1970', mois: '01', jour: '01'
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
    post '/identification', identifiant: '2', annee: '1915', mois: '12', jour: '19'
    post *arguments_du_post
    get arguments_du_post[0]
    Nokogiri::HTML(last_response.body)
  end

  def test_affichage_des_options_choisis_sur_la_page_validation
    eleve = Eleve.create(identifiant: 'XXX', date_naiss: '1970-01-01', niveau_classe_ant: '3')
    etablissement = Etablissement.create(nom: 'college test')
    dossier_eleve = DossierEleve.create(eleve_id: eleve.id, etablissement_id: etablissement.id)
    eleve.option << Option.create(nom: 'anglais', groupe: 'LV1')
    option_choisie = Option.create(nom: 'grec', groupe: 'LCA')
    demande = Demande.create(option_id: option_choisie.id, eleve_id: eleve.id)
    option_abandonnee = Option.create(nom: 'latin', groupe: 'LCA')
    abandon = Abandon.create(option_id: option_abandonnee.id, eleve_id: eleve.id)

    post '/identification', identifiant: 'xxx', annee: '1970', mois: '01', jour: '01'
    get '/validation'

    assert last_response.body.include? 'anglais'
    assert last_response.body.include? "Demande d'inscription à l'option <strong>grec</strong>"
    assert last_response.body.include? "Souhait d'abandonner l'option <strong>latin</strong>"
  end

  def test_affichage_info_sur_options
    eleve = Eleve.find_by(identifiant: 6)
    eleve.update(montee: Montee.create)
    option = Option.create(nom: 'grec', groupe: 'LCA', modalite:'facultative', info: '(sous réserve)')
    demandabilite = Demandabilite.create(option: option, montee: eleve.montee)
    demande = Demande.create(option_id: option.id, eleve_id: eleve.id)

    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'

    get '/validation'
    assert last_response.body.include? "Demande d'inscription à l'option <strong>grec</strong>"

    get '/eleve'
    assert last_response.body.include? 'grec (sous réserve)'
  end

  def test_une_famille_remplit_letape_administration
    post '/identification', identifiant: '2', annee: '1915', mois: '12', jour: '19'
    get '/administration'
    post '/administration', demi_pensionnaire: true, autorise_sortie: true,
      renseignements_medicaux: true, autorise_photo_de_classe: false
    get '/administration'

    assert last_response.body.gsub(/\s/,'').include? "id='demi_pensionnaire' checked".gsub(/\s/,'')
    assert last_response.body.gsub(/\s/,'').include? "id='autorise_sortie' checked".gsub(/\s/,'')
    assert last_response.body.gsub(/\s/,'').include? "id='renseignements_medicaux' checked".gsub(/\s/,'')
    assert last_response.body.gsub(/\s/,'').include? "id='autorise_photo_de_classe' checked".gsub(/\s/,'')
  end

  def test_une_personne_non_identifiée_ne_peut_accéder_à_pièces
    get "/piece/6/assurance_scolaire/nimportequoi"

    assert_equal 302, last_response.status
  end

  def test_famille_peut_accéder_à_une_pièce_de_son_dossier
    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'

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
    valeur_trouvee = doc.css(selecteur_css).attr('value') ? # c'est un input ?
        doc.css(selecteur_css).attr('value').text # oui
      : doc.css(selecteur_css).text # non, on suppose un textarea
    assert_equal valeur_attendue, valeur_trouvee
  end

  def test_affichage_d_options_ogligatoires_a_choisir
    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'
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
    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'
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
    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'
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
    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'
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
    post '/identification', identifiant: '5', annee: '1970', mois: '01', jour: '01'
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
    post '/identification', identifiant: 'XXX', annee: '1970', mois: '01', jour: '01'

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

    post '/identification', identifiant: 'XXX', annee: '1970', mois: '01', jour: '01'
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

    post '/identification', identifiant: '5', annee: '1970', mois: '01', jour: '01'
    get '/unepagequinexistepas'
    assert last_response.body.include? "une page qui n'existe pas"
  end

  def test_erreur_interne
    Sinatra::Application::set :environment, 'production'
    get '/unepagequileveuneexception'
    assert last_response.body.include? "une erreur technique"
    Sinatra::Application::set :environment, 'development'
  end

  def test_affiche_pas_resp_legal_2_si_absent_de_siecle
    e = Eleve.create! identifiant: 'XXX', date_naiss: '1915-12-19'
    dossier_eleve = DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first
    RespLegal.create! dossier_eleve_id: dossier_eleve.id, email: 'test@test.com', priorite: 1

    post '/identification', identifiant: 'XXX', annee: '1915', mois: '12', jour: '19'
    get '/famille'

    doc = Nokogiri::HTML(last_response.body)
    assert_nil doc.css("div#resp_legal_2").first
  end

  # le masquage du formulaire de contact se fait en javascript
  def test_html_du_contact_present_dans_page_quand_pas_encore_de_contact
    e = Eleve.create! identifiant: 'XXX', date_naiss: '1915-12-19'
    dossier_eleve = DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first
    RespLegal.create! dossier_eleve_id: dossier_eleve.id, email: 'test@test.com', priorite: 1

    post '/identification', identifiant: 'XXX', annee: '1915', mois: '12', jour: '19'
    get '/famille'

    doc = Nokogiri::HTML(last_response.body)
    assert_not_nil doc.css("input#tel_principal_urg").first
  end
end
