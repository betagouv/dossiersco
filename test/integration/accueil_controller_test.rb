# frozen_string_literal: true

require 'test_helper'

class AccueilControllerTest < ActionDispatch::IntegrationTest
  def test_accueil
    get '/'
    assert response.parsed_body.include? 'Inscription'
  end

  def test_entree_succes_eleve_vierge
    etablissement = Fabricate(:etablissement)
    eleve = Fabricate(:eleve, identifiant: 'XXX', date_naiss: '1915-12-19', nom: 'Piaf', prenom: 'Edit')

    dossier_eleve = Fabricate(:dossier_eleve, eleve: eleve, etablissement: etablissement)

    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    follow_redirect!
    assert response.parsed_body.include? 'Pour réinscrire votre enfant'
  end

  def _test_normalise_INE
    # en attendant de place cette méthode en dehors du controller
    assert_equal '070803070AJ', normalise_alphanum(' %! 070803070aj _+ ')
  end

  def test_message_erreur_identification
    assert_equal 'Veuillez fournir identifiant et date de naissance', message_erreur_identification(nil, '14-05-2018')
    assert_equal 'Veuillez fournir identifiant et date de naissance', message_erreur_identification('', '14-05-2018')
    assert_equal 'Veuillez fournir identifiant et date de naissance', message_erreur_identification('XXX', nil)
    assert_equal 'Veuillez fournir identifiant et date de naissance', message_erreur_identification('XXX', '')
  end

  def test_entree_succes_eleve_1
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve
    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    follow_redirect!
    assert response.parsed_body.include? 'Pour réinscrire votre enfant'
  end

  def test_entree_mauvaise_date
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: (eleve.jour_de_naissance.to_i + 1.days).to_s }
    follow_redirect!
    assert response.parsed_body.include? html_escape("Nous n'avons pas reconnu ces identifiants, merci de les vérifier.")
  end

  def test_entree_mauvais_identifiant_et_date
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post '/identification', params: { identifiant: 'toto', annee: '1998', mois: '11', jour: '19' }
    follow_redirect!
    assert response.parsed_body.include? html_escape("Nous n'avons pas reconnu ces identifiants, merci de les vérifier.")
  end

  def test_nom_college_accueil
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    follow_redirect!
    doc = Nokogiri::HTML(response.parsed_body)
    assert_equal "Collège #{dossier_eleve.etablissement.nom}", doc.xpath('//div//h1/text()').to_s
    assert_equal "#{dossier_eleve.etablissement.nom}.", doc.xpath("//strong[@id='etablissement']/text()").to_s.strip
  end

  def test_modification_lieu_naiss_eleve
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    post '/eleve', params: { ville_naiss: 'Beziers', prenom: 'Edith' }
    get '/eleve'
    assert response.parsed_body.include? 'Edith'
    assert response.parsed_body.include? 'Beziers'
  end

  def test_modifie_une_information_de_eleve_preserve_les_autres_informations
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    post '/eleve', params: { prenom: 'Edith' }
    get '/eleve'
    assert response.parsed_body.include? 'Edith'
  end

  def test_accueil_et_inscription
    post '/identification', params: { identifiant: '1', annee: '1995', mois: '11', jour: '19' }
    follow_redirect!
    assert response.parsed_body.include? 'inscription'
  end

  def test_persistence_du_resp_legal_1
    doc = soumet_formulaire '/famille', params: { lien_de_parente_rl1: 'TUTEUR', prenom_rl1: 'Philippe', nom_rl1: 'Blayo', adresse_rl1: '20 bd Segur', code_postal_rl1: '75007', ville_rl1: 'Paris', tel_personnel_rl1: '0612345678', tel_portable_rl1: '0112345678', email_rl1: 'test@gmail.com', profession_rl1: 'Retraité cadre, profession interm édiaire', enfants_a_charge_rl1: 3, communique_info_parents_eleves_rl1: 'true' }

    assert_equal 'TUTEUR', doc.css('#lien_de_parente_rl1 option[@selected="selected"]').children.text
    assert_attr 'Philippe', '#prenom_rl1', doc
    assert_attr 'Blayo', '#nom_rl1', doc
    assert_attr '20 bd Segur', '#adresse_rl1', doc
    assert_attr '75007', '#code_postal_rl1', doc
    assert_equal 'PARIS', doc.css('#ville_rl1').children.text.gsub!(/\s+/, '')
    assert_attr '0612345678', '#tel_personnel_rl1', doc
    assert_attr '0112345678', '#tel_portable_rl1', doc
    assert_attr 'test@gmail.com', '#email_rl1', doc
    assert_equal 'Retraité cadre, profession interm édiaire', doc.css('#profession_rl1 option[@selected="selected"]').children.text
    assert_attr '3', '#enfants_a_charge_rl1', doc
    assert_equal 'checked', doc.css('#communique_info_parents_eleves_rl1').attr('checked').text
  end

  def soumet_formulaire(*arguments_du_post)
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    post *arguments_du_post
    get arguments_du_post[0]
    Nokogiri::HTML(response.parsed_body)
  end

  def message_erreur_identification(identifiant, date_naissance)
    mois_de_l_année = {
      '01' => 'janvier', '02' => 'février', '03' => 'mars', '04' => 'avril',
      '05' => 'mai', '06' => 'juin', '07' => 'juillet', '08' => 'août',
      '09' => 'septembre', '10' => 'octobre', '11' => 'novembre', '12' => 'décembre'
    }
    if identifiant.to_s.empty? || date_naissance.to_s.empty?
      return 'Veuillez fournir identifiant et date de naissance'
    end

    annee, mois, jour = normalise(date_naissance).split('-')
    "L'élève a bien comme identifiant #{identifiant} et comme date de naissance le #{jour} #{mois_de_l_année[mois]} #{annee} ?"
  end

  def assert_attr(valeur_attendue, selecteur_css, doc)
    valeur_trouvee = doc.css(selecteur_css).attr('value') ? # c'est un input ?
      doc.css(selecteur_css).attr('value').text # oui
    : doc.css(selecteur_css).text # non, on suppose un textarea
    assert_equal valeur_attendue, valeur_trouvee
  end

  def test_ramène_parent_à_dernière_étape_incomplète
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    post '/eleve', params: { Espagnol: true, Latin: true }
    get '/famille'

    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    follow_redirect!

    doc = Nokogiri::HTML(response.parsed_body)
    assert_equal 'Responsable légal', doc.css('body > main > section > form > h2').text
  end

  def test_une_famille_remplit_letape_administration
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    get '/administration'
    post '/administration', params: { demi_pensionnaire: true, autorise_sortie: true, renseignements_medicaux: true, autorise_photo_de_classe: false }
    get '/administration'

    assert response.parsed_body.gsub(/\s/, '').include? "id='demi_pensionnaire' checked".gsub(/\s/, '')
    assert response.parsed_body.gsub(/\s/, '').include? "id='autorise_sortie' checked".gsub(/\s/, '')
    assert response.parsed_body.gsub(/\s/, '').include? "id='renseignements_medicaux' checked".gsub(/\s/, '')
    assert response.parsed_body.gsub(/\s/, '').include? "id='autorise_photo_de_classe' checked".gsub(/\s/, '')
  end

  # le masquage du formulaire de contact se fait en javascript
  def test_html_du_contact_present_dans_page_quand_pas_encore_de_contact
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    get '/famille'

    doc = Nokogiri::HTML(response.parsed_body)
    assert_not_nil doc.css('input#tel_principal_urg').first
  end

  def test_ramene_a_la_dernire_etape_visitee_plutot_que_l_etape_la_plus_avancee
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    post '/famille'
    get '/eleve'
    post '/deconnexion'
    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    follow_redirect!
    assert response.parsed_body.include? html_escape("Identité de l'élève")
  end

  def test_ramene_a_l_etape_confirmation_pour_la_satisfaction
    resp_legal = Fabricate(:resp_legal)
    eleve = Fabricate(:eleve)
    dossier_eleve = Fabricate(:dossier_eleve, eleve: eleve, resp_legal: [resp_legal])
    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    get '/confirmation'
    post '/satisfaction'
    post '/deconnexion'
    post '/identification', params: { identifiant: eleve.identifiant, annee: eleve.annee_de_naissance, mois: eleve.mois_de_naissance, jour: eleve.jour_de_naissance }
    follow_redirect!

    assert response.parsed_body.include? "L'inscription ne sera validée qu'à réception d'un email de confirmation"
  end
end
