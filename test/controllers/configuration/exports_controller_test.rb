# frozen_string_literal: true

require "test_helper"

class ExportsControllerTest < ActionDispatch::IntegrationTest

  SCHEMA_IMPORT_SIECLE = "./lib/schema_Import_3.1.xsd"

  test "#export-siecle" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp = Fabricate(:resp_legal, email: "")
    dossier_eleve = Fabricate(:dossier_eleve_valide,
                              etablissement: admin.etablissement,
                              resp_legal: [resp])

    resp = Fabricate(:resp_legal, email: nil)
    dossier_eleve = Fabricate(:dossier_eleve_valide,
                              etablissement: admin.etablissement,
                              resp_legal: [resp])

    resp = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve_valide,
                              etablissement: admin.etablissement,
                              resp_legal: [resp])
    3.times do
      resp = Fabricate(:resp_legal)
      dossier_eleve = Fabricate(:dossier_eleve_valide,
                                etablissement: admin.etablissement,
                                resp_legal: [resp])
      option = Fabricate(:option_pedagogique, nom: "un super nom d'option un peu long", obligatoire: "F", code_matiere: "ALGEV")
      dossier_eleve.options_pedagogiques << option
    end

    resp = Fabricate(:resp_legal, enfants_a_charge: 2)
    Fabricate(:dossier_eleve_valide,
              mef_destination: nil,
              etablissement: admin.etablissement,
              resp_legal: [resp])

    get export_siecle_configuration_exports_path(xml_only: true)

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    xsd = Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)
    assert_equal [], xsd.validate(xml)
  end

  test "L'adresse est renseignée dans l'export siècle" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp = Fabricate(:resp_legal,
                     adresse: "3 rue de test",
                     code_postal: "75000",
                     ville: "Ville de test",
                     pays: "100")
    Fabricate(:dossier_eleve_valide,
              etablissement: admin.etablissement,
              resp_legal: [resp])
    %i[adresse code_postal ville pays].each do |partie_du_tag_adresse|
      resp_incomplet = Fabricate(:resp_legal,
                                 adresse: "adresse a ne pas afficher",
                                 code_postal: "75001",
                                 ville: "Ville a ne pas afficher",
                                 pays: "XXX")
      resp_incomplet[partie_du_tag_adresse] = nil
      Fabricate.build(:dossier_eleve_valide,
                      etablissement: admin.etablissement,
                      resp_legal: [resp_incomplet])
    end

    get export_siecle_configuration_exports_path(xml_only: true)

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    xsd = Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)
    assert_equal [], xsd.validate(xml)
    assert_match "3 rue de test", response.body
    assert_match "75000", response.body
    assert_match "Ville de test", response.body
    assert_match "100", response.body
    assert_no_match "adresse a ne pas afficher", response.body
    assert_no_match "75001", response.body
    assert_no_match "Ville a ne pas afficher", response.body
    assert_no_match "XXX", response.body
  end

  test "L'INE est renseigné dans l'ID_NATIONAL" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    eleve = Fabricate(:eleve)
    resp_legal = Fabricate(:resp_legal)
    dossier = Fabricate(:dossier_eleve_valide, eleve: eleve, resp_legal: [resp_legal], etablissement: admin.etablissement)

    get export_siecle_configuration_exports_path(xml_only: true)

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)

    assert_match dossier.eleve.identifiant, xml.css("ID_NATIONAL").text
  end

  test "Pour une naissance à l'étranger, la commune est renseignée sous forme de texte" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    eleve = Fabricate(:eleve, ville_naiss: "KINSHASA", pays_naiss: "324")
    dossier = Fabricate(:dossier_eleve_valide,
                        eleve: eleve,
                        etablissement: admin.etablissement,
                        mef_destination: Fabricate(:mef, etablissement: admin.etablissement))

    get export_siecle_configuration_exports_path(xml_only: true)

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)

    assert_match dossier.eleve.pays_naiss,  xml.css("CODE_PAYS").text
    assert_match dossier.eleve.ville_naiss, xml.css("VILLE_NAISS").text
  end

  test "Pour une naissance à l'étranger sans commune, la commune est renseignée comme inconnue" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    eleve_sans_commune = Fabricate(:eleve, ville_naiss: nil, pays_naiss: "324")
    dossier_sans_commune = Fabricate(:dossier_eleve_valide,
                                     eleve: eleve_sans_commune,
                                     etablissement: admin.etablissement,
                                     mef_destination: Fabricate(:mef, etablissement: admin.etablissement))
    get export_siecle_configuration_exports_path(xml_only: true)

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)

    assert_match dossier_sans_commune.eleve.pays_naiss, xml.css("CODE_PAYS").text
    assert_match "Inconnu", xml.css("VILLE_NAISS").text
  end
  test "export uniquement pour l'INE saisi" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp = Fabricate(:resp_legal,
                     adresse: "3 rue de test",
                     code_postal: "75000",
                     ville: "Ville de test",
                     pays: "FRA")
    autre_resp = Fabricate(:resp_legal,
                           adresse: "8 rue de test",
                           code_postal: "75000",
                           ville: "Ville de test",
                           pays: "FRA")
    dossier = Fabricate(:dossier_eleve_valide,
                        etablissement: admin.etablissement,
                        resp_legal: [resp])
    Fabricate(:dossier_eleve_valide,
              etablissement: admin.etablissement,
              resp_legal: [autre_resp])

    get export_siecle_configuration_exports_path(xml_only: true), params: { limite: true, liste_ine: dossier.eleve.identifiant }

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)

    assert_equal 1, xml.xpath("//ELEVE").count
  end

  test "exporte le CODE_MODALITE_ELECT" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    mef = Fabricate(:mef)
    option = Fabricate(:option_pedagogique)
    Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option, code_modalite_elect: "F")
    dossier = Fabricate(:dossier_eleve_valide,
                        etablissement: admin.etablissement,
                        mef_destination: mef,
                        options_pedagogiques: [option])

    get export_siecle_configuration_exports_path(xml_only: true), params: { limite: true, liste_ine: dossier.eleve.identifiant }

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)

    assert_equal "F", xml.xpath("//CODE_MODALITE_ELECT").text
  end

  test "exporte O comme valeur par défaut de CODE_MODALITE_ELECT" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    mef = Fabricate(:mef)
    option = Fabricate(:option_pedagogique)
    Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option, code_modalite_elect: nil)
    dossier = Fabricate(:dossier_eleve_valide,
                        etablissement: admin.etablissement,
                        mef_destination: mef,
                        options_pedagogiques: [option])

    get export_siecle_configuration_exports_path(xml_only: true), params: { limite: true, liste_ine: dossier.eleve.identifiant }

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)

    assert_equal "O", xml.xpath("//CODE_MODALITE_ELECT").text
  end

  test "utilise le 11e caractère du mef_an_dernier comme TYPE_MEF dans le fichier d'export" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    dossier = Fabricate(:dossier_eleve_valide, etablissement: admin.etablissement, mef_an_dernier: "12345678009")

    get export_siecle_configuration_exports_path(xml_only: true), params: { limite: true, liste_ine: dossier.eleve.identifiant }

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)

    assert_equal "9", xml.xpath("//TYPE_MEF").text
  end

  test "retourne les options dans l'ordre de leur RANG_OPTION, suivi des options facultatives" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    mef = Fabricate(:mef)
    option_facultative = Fabricate(:option_pedagogique, code_matiere_6: "033333")
    option_de_rang_2 = Fabricate(:option_pedagogique, code_matiere_6: "020002")
    option_de_rang_1 = Fabricate(:option_pedagogique, code_matiere_6: "010001")
    Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option_facultative, rang_option: nil)
    Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option_de_rang_2, rang_option: 2)
    Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option_de_rang_1, rang_option: 1)
    dossier = Fabricate(:dossier_eleve_valide,
                        etablissement: admin.etablissement,
                        mef_destination: mef,
                        options_pedagogiques: [option_facultative, option_de_rang_2, option_de_rang_1])

    get export_siecle_configuration_exports_path(xml_only: true), params: { limite: true, liste_ine: dossier.eleve.identifiant }

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)

    options = xml.xpath("//SCOLARITE_ACTIVE/OPTIONS/OPTION")
    assert_equal option_de_rang_1.code_matiere_6, options[0].xpath("CODE_MATIERE").text
    assert_equal option_de_rang_2.code_matiere_6, options[1].xpath("CODE_MATIERE").text
    assert_equal option_facultative.code_matiere_6, options[2].xpath("CODE_MATIERE").text
  end

  test "retourne l'information à propos du paiement des frais de scolarité" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp_qui_paie = Fabricate(:resp_legal, paie_frais_scolaires: true)
    resp_qui_paie_pas = Fabricate(:resp_legal, paie_frais_scolaires: false)
    dossier = Fabricate(:dossier_eleve_valide, etablissement: admin.etablissement, resp_legal: [resp_qui_paie, resp_qui_paie_pas])

    get export_siecle_configuration_exports_path(xml_only: true), params: { limite: true, liste_ine: dossier.eleve.identifiant }

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)

    responsables = xml.xpath("//ELEVES/ELEVE/RESPONSABLES_ELEVE/LEGAL")
    assert_equal 2, responsables.length
    responsables.each do |noeud_legal|
      id_prv_resp = noeud_legal.xpath("ID_PRV_PER").text
      paie_frais_scolaires = noeud_legal.xpath("PAIE_FRAIS_SCOLAIRES").text
      if id_prv_resp == resp_qui_paie.id.to_s
        assert_equal "1", paie_frais_scolaires
      else
        assert_equal "0", paie_frais_scolaires
      end
    end
  end

  test "ne génére pas de balise division si pas de division" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    Fabricate(:dossier_eleve_valide,
              etablissement: admin.etablissement,
              division: nil, division_an_dernier: nil)

    get export_siecle_configuration_exports_path(xml_only: true)

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))

    assert_no_match "CODE_DIVISION", response.body
  end

  test "n'exporte que les élèves avec une mef destination conforme au xsd " do
    admin = Fabricate(:admin)
    identification_agent(admin)

    mef_non_conforme = Fabricate(:mef, code: "ACREER POUR BILANGUEALLEMAND")
    option = Fabricate(:option_pedagogique)
    Fabricate(:mef_option_pedagogique, mef: mef_non_conforme, option_pedagogique: option, code_modalite_elect: "F")
    Fabricate(:dossier_eleve_valide,
              etablissement: admin.etablissement,
              mef_destination: mef_non_conforme,
              options_pedagogiques: [option])

    get export_siecle_configuration_exports_path(xml_only: true)

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))

    assert_no_match mef_non_conforme.code, response.body
  end

  test "exporte sur deux lignes une adresse de plus de 38 caractères" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp_longue_adresse = Fabricate(:resp_legal,
                                    adresse: "A" * 35 + " Dépasse 38 caractères")
    Fabricate(:dossier_eleve_valide,
              etablissement: admin.etablissement,
              resp_legal: [resp_longue_adresse])
    xml = recupere_fichier_xml_de_retour_siecle

    assert_match "Dépasse 38 caractères", xml.css("LIGNE2_ADRESSE").text
  end

  test "exporte les seconds et troisièmes prénoms" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    eleve_avec_3_prenoms = Fabricate(:eleve,
                                     prenom_2: "PRENOM 2",
                                     prenom_3: "PRENOM 3")
    Fabricate(:dossier_eleve_valide,
              eleve: eleve_avec_3_prenoms,
              etablissement: admin.etablissement)

    xml = recupere_fichier_xml_de_retour_siecle

    assert_equal "PRENOM 2", xml.css("PRENOM2").text
    assert_equal "PRENOM 3", xml.css("PRENOM3").text
  end

  test "n'exporte pas des seconds et troisièmes prénoms vides" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    eleve_avec_prenoms_vides = Fabricate(:eleve,
                                         prenom_2: "",
                                         prenom_3: "")
    Fabricate(:dossier_eleve_valide,
              eleve: eleve_avec_prenoms_vides,
              etablissement: admin.etablissement)

    recupere_fichier_xml_de_retour_siecle

    assert_no_match "PRENOM2", response.body
    assert_no_match "PRENOM3", response.body
  end

  test "pas de code postal si ville à l'étrange" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp_legal = Fabricate(:resp_legal, pays: "140", code_postal: "1207", ville: "GENEVE")
    Fabricate(:dossier_eleve_valide, resp_legal: [resp_legal], etablissement: admin.etablissement)

    recupere_fichier_xml_de_retour_siecle

    assert_match "COMMUNE_ETRANGERE", response.body
    assert_no_match "LL_POSTAL", response.body
    assert_no_match "CODE_POSTAL", response.body
  end

  test "le code CIVILITE doit être 2 pour une civilité MME" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp_legal = Fabricate(:resp_legal, civilite: "MME")
    Fabricate(:dossier_eleve_valide, resp_legal: [resp_legal], etablissement: admin.etablissement)

    xml = recupere_fichier_xml_de_retour_siecle

    assert_equal "2", xml.xpath("//CODE_CIVILITE").text
  end

  test "le code CIVILITE doit être 1 pour une civilité MR" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp_legal = Fabricate(:resp_legal, civilite: "M.")
    Fabricate(:dossier_eleve_valide, resp_legal: [resp_legal], etablissement: admin.etablissement)

    xml = recupere_fichier_xml_de_retour_siecle

    assert_equal "1", xml.xpath("//CODE_CIVILITE").text
  end

  test "on export un contact en cas d'urgence dans les personnes si présent" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    contact_urgence = Fabricate(:contact_urgence)
    Fabricate(:dossier_eleve_valide, contact_urgence: contact_urgence, etablissement: admin.etablissement)

    xml = recupere_fichier_xml_de_retour_siecle

    assert_equal contact_urgence.id.to_s, xml.xpath("/IMPORT_ELEVES/DONNEES/PERSONNES/PERSONNE/ID_PRV_PER").text
    assert xml.xpath("/IMPORT_ELEVES/DONNEES/PERSONNES/PERSONNE/NOM_DE_FAMILLE").map(&:text).include?(contact_urgence.nom)
    assert xml.xpath("/IMPORT_ELEVES/DONNEES/PERSONNES/PERSONNE/PRENOM").map(&:text).include?(contact_urgence.prenom)
  end

  test "ajoute un contact en cas d'urgence à l'élève" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    contact_urgence = Fabricate(:contact_urgence, lien_de_parente: "AUTRE LIEN")
    Fabricate(:dossier_eleve_valide, contact_urgence: contact_urgence, etablissement: admin.etablissement)

    xml = recupere_fichier_xml_de_retour_siecle

    assert_equal 1, xml.xpath("/IMPORT_ELEVES/DONNEES/ELEVES/ELEVE/RESPONSABLES_ELEVE/CONTACT").count
    assert_equal contact_urgence.id.to_s, xml.xpath("/IMPORT_ELEVES/DONNEES/ELEVES/ELEVE/RESPONSABLES_ELEVE/CONTACT/ID_PRV_PER").text
    assert_equal "90", xml.xpath("/IMPORT_ELEVES/DONNEES/ELEVES/ELEVE/RESPONSABLES_ELEVE/CONTACT/CODE_PARENTE").text
  end

  def recupere_fichier_xml_de_retour_siecle
    get export_siecle_configuration_exports_path(xml_only: true)

    assert_response :success

    schema = Rails.root.join(SCHEMA_IMPORT_SIECLE)
    Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)

    assert_empty xml.errors
    xml
  end

end
