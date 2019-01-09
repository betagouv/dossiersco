require 'test_helper'
require 'fixtures'
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


end

