# frozen_string_literal: true

require "test_helper"

class InscriptionsControllerTest < ActionDispatch::IntegrationTest

  def test_nombre_dossiers_total
    agent = Fabricate(:agent)
    5.times { Fabricate(:dossier_eleve, etablissement: agent.etablissement, resp_legal: [Fabricate(:resp_legal)]) }

    identification_agent(agent)
    doc = Nokogiri::HTML(response.body)
    selector = "#total_dossiers"
    affichage_total_dossiers = doc.css(selector).text
    assert_equal "5", affichage_total_dossiers
  end

  def test_affiche_message_que_limport_est_en_cours
    agent = Fabricate(:admin)
    identification_agent(agent)

    post "/tache_imports", params: { tache_import: { fichier: "tests/test_import_siecle.xls", job_klass: "ImporterSiecle" } }
    follow_redirect!

    doc = Nokogiri::HTML(response.body)

    assert_match I18n.t("tache_imports.create.message_de_succes", email: agent.email), doc.css(".success").text
  end

  def test_destinataire_sms
    dossier = DossierEleve.new
    dossier.resp_legal = [
      RespLegal.new(
        tel_personnel: "01 12 34 56 78", tel_portable: "06 12 34 56 78", priorite: 1
      ),
      RespLegal.new(
        tel_personnel: "01 12 34 56 78", tel_portable: "06 12 34 56 99", priorite: 2
      )
    ]
    message = Message.new(dossier_eleve: dossier, categorie: "sms")
    assert_equal "06 12 34 56 78", message.numero
    message.destinataire = "rl2"
    assert_equal "06 12 34 56 99", message.numero
  end

  test "dossier rl1 == tel portable du resp legal prio 1" do
    dossier = DossierEleve.new
    dossier.resp_legal = [RespLegal.new(
      tel_personnel: "01 12 34 56 78", tel_portable: "06 12 34 56 78", priorite: 1
    )]
    assert_equal "06 12 34 56 78", dossier.portable_rl1
  end

  test "dossier rl1 == tel perso quand pas de portable" do
    dossier = DossierEleve.new
    dossier.resp_legal = [RespLegal.new(
      tel_personnel: "06 12 34 56 78", tel_portable: nil, priorite: 1
    )]
    assert_equal "06 12 34 56 78", dossier.portable_rl1
  end

  test "rl1 == tel perso quand tel portable est un 01 et tel perso un 06" do
    dossier = DossierEleve.new
    dossier.resp_legal = [RespLegal.new(
      tel_personnel: "06 12 34 56 78", tel_portable: "01 12 34 56 78", priorite: 1
    )]
    assert_equal "06 12 34 56 78", dossier.portable_rl1
  end

  test "rl1 == tel portable si commence par 06, même si le tel perso commence par 07" do
    dossier = DossierEleve.new
    dossier.resp_legal = [RespLegal.new(
      tel_personnel: "07 12 34 56 78", tel_portable: "06 12 34 56 78", priorite: 1
    )]
    assert_equal "06 12 34 56 78", dossier.portable_rl1
  end

  def test_portable_rl2
    dossier = DossierEleve.new
    dossier.resp_legal = [RespLegal.new(
      tel_personnel: "01 12 34 56 78", tel_portable: "06 12 34 56 78", priorite: 1
    )]
    assert_nil dossier.portable_rl2
    dossier.resp_legal << RespLegal.new(
      tel_personnel: "01 12 34 56 78", tel_portable: "06 12 34 56 99", priorite: 2
    )
    assert_equal "06 12 34 56 99", dossier.portable_rl2
  end

  def test_un_agent_visualise_un_eleve
    resp_legal = Fabricate(:resp_legal)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    agent = Fabricate(:agent, etablissement: dossier.etablissement)
    identification_agent(agent)

    get "/agent/eleve/#{dossier.eleve.identifiant}"

    assert response.body.include? dossier.eleve.nom
    assert response.body.include? dossier.eleve.prenom
  end

  def test_valide_une_inscription
    resp_legal = Fabricate(:resp_legal, priorite: 1)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    etablissement = dossier.etablissement
    eleve = dossier.eleve
    agent = Fabricate(:agent, etablissement: etablissement)

    identification_agent(agent)

    post "/agent/valider_inscription", params: { identifiant: eleve.identifiant }
    assert_equal "validé", dossier.reload.etat

    get "/agent/eleve/#{eleve.identifiant}"
    doc = Nokogiri::HTML(response.body)
    assert_equal "disabled", doc.css("#bouton-validation-inscription").first.attributes["disabled"].value
  end

  def test_un_eleve_est_sortant
    resp_legal = Fabricate(:resp_legal)
    dossier = Fabricate(:dossier_eleve, etat: "sortant", resp_legal: [resp_legal])
    agent = Fabricate(:agent, etablissement: dossier.etablissement)
    identification_agent(agent)

    post "/agent/eleve_sortant", params: { identifiant: dossier.eleve.identifiant }
    eleve = dossier.eleve
    assert_equal "sortant", eleve.dossier_eleve.etat

    get "/agent/eleve/#{eleve.identifiant}"
    doc = Nokogiri::HTML(response.body)
    assert_equal "disabled", doc.css("#bouton-eleve-sortant").first.attributes["disabled"].value
  end

  def test_liste_des_eleves
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    agent = Fabricate(:agent, etablissement: dossier_eleve.etablissement)
    identification_agent(agent)

    get "/agent/liste_des_eleves"

    assert response.body.include? dossier_eleve.eleve.nom
    assert response.body.include? dossier_eleve.eleve.prenom
  end

  def test_affiche_changement_adresse_liste_eleves
    # Si on a un changement d'adresse
    resp_legal = Fabricate(:resp_legal, priorite: 1, adresse_ant: "ancienne adresse")
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    resp_legal = dossier.resp_legal_1
    resp_legal.adresse = "Nouvelle adresse"
    resp_legal.save

    agent = Fabricate(:agent, etablissement: dossier.etablissement)
    identification_agent(agent)
    get "/agent/liste_des_eleves"

    assert response.body.include? "✓"
  end

  def test_affiche_demi_pensionnaire
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    dossier_eleve.update(demi_pensionnaire: true)

    agent = Fabricate(:agent, etablissement: dossier_eleve.etablissement)
    identification_agent(agent)
    get "/agent/liste_des_eleves"

    assert response.body.include? "✓"
  end

  test "affiche l'email du resp_legal" do
    etablissement = Fabricate(:etablissement)
    eleve = Fabricate(:eleve, identifiant: "XXX")
    dossier_eleve = Fabricate(:dossier_eleve, eleve: eleve, etablissement: etablissement)
    Fabricate(:resp_legal, dossier_eleve: dossier_eleve, email: "test@test.com", priorite: 1)

    agent = Fabricate(:agent, etablissement: dossier_eleve.etablissement)
    identification_agent(agent)

    get "/agent/eleve/XXX"

    assert response.body.include? "test@test.com"
  end

  def test_affiche_contacts
    Eleve.create! identifiant: "XXX"

    resp_legal = Fabricate(:resp_legal,
                           tel_personnel: "0101010101",
                           tel_portable: "0606060606",
                           email: "test@test.com",
                           priorite: 1)

    contact_urgence = Fabricate(:contact_urgence, tel_principal: "0103030303")
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal], contact_urgence: contact_urgence)

    agent = Fabricate(:agent, etablissement: dossier_eleve.etablissement)
    identification_agent(agent)
    get "/agent/eleve/#{dossier_eleve.eleve.identifiant}"

    assert response.body.include? "0101010101"
    assert response.body.include? "0606060606"
    assert response.body.include? "0103030303"
  end

  def test_affiche_lenveloppe_uniquement_si_un_des_resp_legal_a_un_mail
    resp_legal = Fabricate(:resp_legal, priorite: 1, email: "test@example.com")
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])

    agent = Fabricate(:agent, etablissement: dossier_eleve.etablissement)
    identification_agent(agent)
    get "/agent/liste_des_eleves"

    assert response.body.include? "far fa-envelope"
  end

  test "crée un message pour garder une trace" do
    etablissement = Fabricate(:etablissement, envoyer_aux_familles: true)
    resp_legal = Fabricate(:resp_legal, priorite: 1)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal], etablissement: etablissement)
    agent = Fabricate(:agent, etablissement: etablissement)
    identification_agent(agent)

    post "/agent/contacter_une_famille", params: {
      identifiant: dossier.eleve.identifiant,
      message: "Message de test",
      moyen_de_communication: resp_legal.email
    }

    get "/agent/liste_des_eleves"

    assert_equal 1, Message.count
    assert_equal "mail", Message.first.categorie
  end

  def test_changement_statut_famille_connecte
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post "/identification", params: {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }

    assert_equal "connecté", dossier_eleve.reload.etat

    agent = Fabricate(:agent, etablissement: dossier_eleve.etablissement)
    identification_agent(agent)
    get "/agent/liste_des_eleves"

    assert response.body.include? "connecté"
  end

  def test_changement_statut_famille_en_cours_de_validation
    dossier = Fabricate(:dossier_eleve)
    eleve = dossier.eleve

    post "/identification", params: {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    post "/validation"

    dossier.reload
    assert_equal "en attente de validation", dossier.etat
  end

  test "n'envoie rien si aucun moyen de communication fourni" do
    ActionMailer::Base.deliveries = []
    resp_legal = Fabricate(:resp_legal, email: "phill@collins.uk")
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])

    agent = Fabricate(:agent, etablissement: dossier_eleve.etablissement)
    identification_agent(agent)

    post "/agent/contacter_une_famille", params: { identifiant: dossier_eleve.eleve.identifiant, message: "Message de test" }

    assert_equal "Aucun moyen de communication choisi", flash[:alert]
    assert_equal 0, ActionMailer::Base.deliveries.count
    assert_equal 0, Message.where(categorie: "sms").count
  end

  test "trace messages envoyes" do
    assert_equal 0, Message.count

    etablissement = Fabricate(:etablissement, envoyer_aux_familles: true)
    resp_legal = Fabricate(:resp_legal)
    dossier = Fabricate(:dossier_eleve,
                        etablissement: etablissement,
                        resp_legal: [resp_legal])
    agent = Fabricate(:agent, etablissement: etablissement)

    identification_agent(agent)
    post "/agent/contacter_une_famille", params: {
      identifiant: dossier.eleve.identifiant,
      message: "Message de test",
      moyen_de_communication: "truc@example.com"
    }

    assert_equal 1, Message.count
    message = Message.first
    assert_equal "mail", message.categorie
    assert_equal dossier.id, message.dossier_eleve_id
    assert_equal "envoyé", message.etat
  end

  def test_stats
    etablissement_un = Fabricate(:etablissement)
    etablissement_deux = Fabricate(:etablissement)
    Fabricate(:agent, etablissement: etablissement_un, jeton: "jeton_de_test")
    Fabricate(:agent, etablissement: etablissement_deux, jeton: "jeton_de_test")

    get "/stats"

    crees_mais_non_connectes = Nokogiri::HTML(response.body).xpath("/html/body/main/section[1]/h2/text()").to_s
    assert_match "Établissements inscrits (#{Etablissement.count})", crees_mais_non_connectes
  end

  def test_page_eleve_agent_affiche_changement_adresse
    resp_legal = Fabricate(:resp_legal, priorite: 1, adresse: "truc", adresse_ant: "truc")
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])

    resp_legal.update adresse: "Nouvelle adresse"
    assert !resp_legal.adresse_inchangee

    agent = Fabricate(:agent, etablissement: dossier.etablissement)
    identification_agent(agent)
    get "/agent/eleve/#{dossier.eleve.identifiant}"

    doc = Nokogiri::HTML(response.body)
    assert_not_nil doc.css("div#ancienne_adresse").first
  end

  def test_page_eleve_agent_affiche_adresse_sans_changement
    eleve = Fabricate(:eleve, identifiant: "truc")
    resp_legal = Fabricate(:resp_legal)
    Fabricate(:dossier_eleve, eleve: eleve, resp_legal: [resp_legal])
    agent = Fabricate(:agent)
    identification_agent(agent)

    get "/agent/eleve/#{eleve.identifiant}"

    doc = Nokogiri::HTML(response.body)
    assert_nil doc.css("div#ancienne_adresse").first
  end

  def test_un_agent_voit_un_commentaire_parent_dans_vue_eleve
    etablissement = Fabricate(:etablissement)
    e = Eleve.create! identifiant: "XXX"
    d = DossierEleve.create! eleve_id: e.id, etablissement_id: etablissement.id, commentaire: "Commentaire de test"
    Fabricate(:resp_legal, dossier_eleve: d)

    agent = Fabricate(:agent, etablissement: d.etablissement)
    identification_agent(agent)
    get "/agent/eleve/XXX"

    doc = Nokogiri::HTML(response.body)
    assert_equal "#{d.satisfaction} : Commentaire de test", doc.css("div#commentaire").first.text
  end

end
