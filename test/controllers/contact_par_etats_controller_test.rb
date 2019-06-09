# frozen_string_literal: true

require "test_helper"

class  ContactParEtatsControllerTest < ActionDispatch::IntegrationTest

  test "affiche une page pour envoyer un message" do
    etablissement = Fabricate(:etablissement, envoyer_aux_familles: true)
    admin = Fabricate(:admin, etablissement: etablissement)
    identification_agent(admin)

    resp_legal = Fabricate(:resp_legal, email: "steve@apple.com")
    Fabricate(:dossier_eleve, etat: "pas connecté", etablissement: etablissement, resp_legal: [resp_legal])

    get new_contact_par_etat_url

    assert_response :success
    assert_equal [["1 dossier(s) pas connecté", :pas_connecte]], assigns(:etats_et_emails_quantite)
  end

  test "envoie un mail pour chaque élèves dont l'état du dossier correspond à celui choisi" do
    etablissement = Fabricate(:etablissement, envoyer_aux_familles: true)
    admin = Fabricate(:admin, etablissement: etablissement)
    identification_agent(admin)

    resp_legal = Fabricate(:resp_legal, email: "steve@apple.com")
    Fabricate(:dossier_eleve, etat: "pas connecté", etablissement: etablissement, resp_legal: [resp_legal])

    resp_legal_sans_email = Fabricate(:resp_legal, email: nil)
    Fabricate(:dossier_eleve, etat: "pas connecté", etablissement: etablissement, resp_legal: [resp_legal_sans_email])

    assert_equal 0, ActionMailer::Base.deliveries.count

    post contact_par_etat_url, params: { message: "un message", etat: "pas_connecte" }

    assert_equal 1, ActionMailer::Base.deliveries.count
    assert_redirected_to "/agent/liste_des_eleves"
    assert_equal "1 dossier(s) avec un email. 1 dossier(s) sans email n'ont pas pu être contacté(s)", flash[:notice]
  end

end
