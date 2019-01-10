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

  def test_liste_des_eleves
    eleve = Eleve.find_by(identifiant: 2)

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/liste_des_eleves'
    doc = Nokogiri::HTML(last_response.body)

    assert_equal "Edith", doc.css("##{eleve.dossier_eleve.id} td:nth-child(4)").text.strip
    assert_equal "Piaf", doc.css("##{eleve.dossier_eleve.id} td:nth-child(5)").text.strip
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
    assert doc.css("##{dossier_eleve.id} td:nth-child(10) a i.fa-file-image").present?
    assert_equal "color: #00cf00", doc.css("##{dossier_eleve.id} td:nth-child(10) i.fa-check-circle").attr("style").text
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
    assert_equal "✓", doc.css("tbody > tr:nth-child(1) > td:nth-child(8)").text.strip
  end

  def test_affiche_demi_pensionnaire
    eleve = Eleve.find_by(identifiant: 2)
    dossier_eleve = eleve.dossier_eleve
    dossier_eleve.update(demi_pensionnaire: true)

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/liste_des_eleves'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "✓", doc.css("tbody > tr:nth-child(1) > td:nth-child(9)").text.strip
  end

  def test_affiche_lenvoi_de_message_uniquement_si_un_des_resp_legal_a_un_mail
    e = Eleve.create! identifiant: 'XXX'
    dossier_eleve = DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first.id
    RespLegal.create! dossier_eleve_id: dossier_eleve.id, email: 'test@test.com', priorite: 1

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get "/agent/eleve/XXX"

    assert last_response.body.include? "Ce formulaire envoie un message à la famille de l'élève."
  end

  def test_affiche_contacts
    e = Eleve.create! identifiant: 'XXX'
    dossier_eleve = DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first.id
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

  def test_affiche_decompte_historique_message_envoyes
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/contacter_une_famille', identifiant: '2', message: 'Message de test'
    get '/agent/liste_des_eleves'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal " (1)", doc.css("tbody > tr:nth-child(1) > td:last-child").text.strip
  end

  def test_changement_statut_famille_connecte
    post '/identification', identifiant: '2', annee: '1915', mois: '12', jour: '19'
    dossier_eleve = Eleve.find_by(identifiant: '2').dossier_eleve
    assert_equal 'connecté', dossier_eleve.etat

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/liste_des_eleves'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "connecté", doc.css("tbody > tr:nth-child(1) > td:nth-child(6)").text.strip
  end

  def test_changement_statut_famille_en_cours_de_validation
    post '/identification', identifiant: '2', annee: '1915', mois: '12', jour: '19'
    post '/validation'
    dossier_eleve = Eleve.find_by(identifiant: '2').dossier_eleve
    assert_equal 'en attente de validation', dossier_eleve.etat

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/liste_des_eleves'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "en attente de validation", doc.css("tbody > tr:nth-child(1) > td:nth-child(6)").text.strip
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

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/contacter_une_famille', identifiant: '6', message: 'Message de test'

    assert_equal 0, ActionMailer::Base.deliveries.count
    assert_equal 1, Message.where(categorie:"sms").count
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

  def test_lenvoie_dun_email_de_relance
    eleve = Eleve.find_by(identifiant: 2)
    template = "Réinscription de votre enfant <%= eleve.prenom %> <%= eleve.nom %> au collège"
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/relance_emails', ids: eleve.dossier_eleve.id, template: template

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
    assert_equal "width: 100.0%;", doc.css(pas_connecte)[1].attr("style")
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

  def test_un_agent_voit_un_commentaire_parent_dans_vue_eleve
    e = Eleve.create! identifiant: 'XXX'
    d = DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first.id, commentaire: "Commentaire de test"
    RespLegal.create! dossier_eleve_id: d.id,
      tel_principal: '0101010101', tel_secondaire: '0606060606', email: 'test@test.com', priorite: 1

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get "/agent/eleve/XXX"

    doc = Nokogiri::HTML(last_response.body)
    assert_equal "#{d.satisfaction} : Commentaire de test", doc.css("div#commentaire").first.text
  end

  def test_historique_messages_envoyes
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/contacter_une_famille', identifiant: '2', message: 'Message 1'
    post '/agent/contacter_une_famille', identifiant: '2', message: 'Message 2'
    get "/agent/eleve/2"
    doc = Nokogiri::HTML(last_response.body)
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

    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    post '/agent/valider_plusieurs_dossiers', ids: ids

    assert_equal 2, ActionMailer::Base.deliveries.count

    dossier_eleve1 = DossierEleve.find(dossier_eleve1.id)
    dossier_eleve2 = DossierEleve.find(dossier_eleve2.id)

    assert_equal 'validé', dossier_eleve2.etat
    assert_equal 'validé', dossier_eleve1.etat
  end

  def test_propose_modeles_messages
    modele = Modele.create(nom: "Cantine")
    Agent.find_by(identifiant: "pierre").etablissement.modele << modele
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get '/agent/eleve/4'

    doc = Nokogiri::HTML(last_response.body)
    assert_equal 'Cantine', doc.css('select#modeles option').text
    assert_equal modele.id.to_s, doc.css('select#modeles option').attr("value").text
  end

  def test_rendu_modele
    modele = Modele.create(nom: "Cantine", contenu: "Salut <%= eleve.prenom %>")
    Agent.find_by(identifiant: "pierre").etablissement.modele << modele
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'
    get "/agent/fusionne_modele/#{modele.id}/eleve/4"
    assert_equal "Salut Pierre", last_response.body
  end

  def test_affichage_preview_jpg_cote_agent
    eleve = Eleve.find_by(identifiant: 6)
    piece_attendue = PieceAttendue.find_by(code: 'assurance_scolaire',
      etablissement_id: eleve.dossier_eleve.etablissement.id)
    piece_jointe = PieceJointe.create(clef: 'assurance_photo.jpg', dossier_eleve_id: eleve.dossier_eleve.id,
      piece_attendue_id: piece_attendue.id)
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    get '/agent/eleve/6'

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

  def test_affichage_preview_pdf_cote_agent
    eleve = Eleve.find_by(identifiant: 6)
    piece_attendue = PieceAttendue.find_by(code: 'assurance_scolaire',
      etablissement_id: eleve.dossier_eleve.etablissement.id)
    piece_jointe = PieceJointe.create(clef: 'assurance_scannee.pdf', dossier_eleve_id: eleve.dossier_eleve.id,
      piece_attendue_id: piece_attendue.id)
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    get '/agent/eleve/6'

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

  def test_affiche_options
    eleve1 = Eleve.find_by(nom: 'Piaf')
    eleve2 = Eleve.find_by(identifiant: 3)
    eleve2.dossier_eleve.update(etat: 'sortant')
    latin = Option.create(nom: 'latin', groupe: 'LCA')
    eleve1.option << latin
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    get '/agent/options'

    doc = Nokogiri::HTML(last_response.body)
    assert ! last_response.body.include?(eleve2.prenom)
    assert_equal "latin", doc.css("tbody > tr:nth-child(1) > td:nth-child(5)").text.strip
  end

  def test_liste_resp_legaux
    eleve = Eleve.find_by(nom: 'Piaf')
    eleve.dossier_eleve.update(etat: "pas connecté")
    eleve_2 = Eleve.find_by(nom: 'Blayo')
    eleve_2.dossier_eleve.update(etat: "connecté")
    post '/agent', identifiant: 'pierre', mot_de_passe: 'demaulmont'

    get '/agent/convocations'

    resp_legal_1 = eleve.dossier_eleve.resp_legal.find {|d| d.priorite == 1}
    resp_legal_1_eleve_2 = eleve_2.dossier_eleve.resp_legal.find {|d| d.priorite == 1}
    doc = Nokogiri::HTML(last_response.body)
    assert_equal resp_legal_1.prenom, doc.css("tbody > tr:nth-child(1) > td:nth-child(4)").text.strip
    assert_equal resp_legal_1.nom, doc.css("tbody > tr:nth-child(1) > td:nth-child(5)").text.strip
    assert_equal resp_legal_1.tel_principal, doc.css("tbody > tr:nth-child(1) > td:nth-child(6)").text.strip
    assert_equal resp_legal_1.tel_secondaire, doc.css("tbody > tr:nth-child(1) > td:nth-child(7)").text.strip
    assert_equal resp_legal_1_eleve_2.prenom, doc.css("tbody > tr:nth-child(2) > td:nth-child(4)").text.strip
  end
end
