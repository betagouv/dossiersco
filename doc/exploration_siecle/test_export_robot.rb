ENV['RACK_ENV'] = 'test'

require 'nokogiri'
require 'test/unit'
require 'rack/test'
require 'tempfile'

require_relative '../helpers/rs/singulier_francais'
require_relative '../helpers/export_siecle'

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

  def test_export_xml
    etablissement = Etablissement.first
    doc = Nokogiri::XML(export_xml(etablissement, [], 'export_xml_robot'))
    assert_equal "DOSSIERSCO", doc.xpath("/IMPORT_ELEVES/PARAMETRES/LOGICIEL").text()
  end

  def test_export_xml_contient_tous_les_eleves_de_l_etablissement
    etablissement = Etablissement.create
    dossier_eleve_1 = cree_dossier_eleve({}, etablissement, 'validé')
    dossier_eleve_2 = cree_dossier_eleve({}, etablissement, 'validé')
    doc = Nokogiri::XML(export_xml(etablissement, [], 'export_xml_robot'))
    assert_equal etablissement.dossier_eleve.count, doc.xpath("/IMPORT_ELEVES/DONNEES/ELEVES/ELEVE").count
  end

  def test_export_xml_contient_tous_les_resp_legaux_d_un_eleve
    etablissement = Etablissement.create
    dossier_eleve = cree_dossier_eleve({}, etablissement, 'validé')
     doc = Nokogiri::XML(export_xml(etablissement, [], 'export_xml_robot'))
    assert_equal dossier_eleve.resp_legal.count, doc.xpath("/IMPORT_ELEVES/DONNEES/ELEVES/ELEVE/RESPONSABLES_ELEVE/*").count
  end

  def test_export_xml_contient_tous_les_resp_legaux_de_deux_eleves
    etablissement = Etablissement.create
    dossier_eleve_1 = cree_dossier_eleve({}, etablissement, 'validé')
    dossier_eleve_2 = cree_dossier_eleve({}, etablissement, 'validé')
    doc = Nokogiri::XML(export_xml(etablissement, [], 'export_xml_robot'))
    ['1','2'].each do |i|
      assert_equal 2, doc.xpath("/IMPORT_ELEVES/DONNEES/ELEVES/ELEVE[#{i}]/RESPONSABLES_ELEVE/LEGAL").count
    end
  end

  def test_export_xml_sait_recopier_des_champs
    etablissement = Etablissement.create
    identite_eleve = {identifiant: 'XXX', nom: 'Martin', prenom: 'Jean', date_naiss: '1970-01-01'}
    dossier_eleve = cree_dossier_eleve(identite_eleve, etablissement, 'validé')
    dossier_eleve.update(demi_pensionnaire: true)
    mappings = [Mapping.new(:identifiant, 'ID_NATIONAL'),
                Mapping.new(:nom, 'NOM_DE_FAMILLE'),
                Mapping.new(:prenom, 'PRENOM'),
                Mapping.new(:date_naiss, 'DATE_NAISS')]
    doc = Nokogiri::XML(export_xml(etablissement, mappings, 'export_xml_robot'))
    structure = "/IMPORT_ELEVES/DONNEES/ELEVES/ELEVE[1]/"
    mappings.each do |mapping|
      assert_equal identite_eleve[mapping.source], doc.xpath("#{structure}#{mapping.cible}").text
    end
    assert_equal '2', doc.xpath("#{structure}CODE_REGIME").text
  end

  def test_li_les_champs_dun_resp_legal
    etablissement = Etablissement.create
    identite_eleve = {identifiant: 'XXX', nom: 'Martin', prenom: 'Jean', date_naiss: '1970-01-01'}
    dossier_eleve = cree_dossier_eleve(identite_eleve, etablissement, 'validé')
    mappings = []
    doc = Nokogiri::XML(export_xml(etablissement, mappings, 'export_xml_robot'))
    structure = "/IMPORT_ELEVES/DONNEES/ELEVES/ELEVE[1]/RESPONSABLES_ELEVE/LEGAL[1]/"
    assert_equal 'Blayo', doc.xpath("#{structure}NOM_DE_FAMILLE").text
    assert_equal 'Jean', doc.xpath("#{structure}PRENOM").text
    assert_equal '42 rue du départ', doc.xpath("#{structure}ADRESSE/LIGNE1_ADRESSE").text
    assert_equal '75018', doc.xpath("#{structure}ADRESSE/CODE_POSTAL").text
    assert_equal 'Paris', doc.xpath("#{structure}ADRESSE/LL_POSTAL").text
    assert_equal 'false', doc.xpath("#{structure}COMMUNICATION_ADRESSE").text
    assert_equal '0123456789', doc.xpath("#{structure}TEL_PERSONNEL").text
    assert_equal '0602020202', doc.xpath("#{structure}TEL_PORTABLE").text
    assert_equal '2', doc.xpath("#{structure}ENFANT_A_CHARGE").text
    assert_equal '21', doc.xpath("#{structure}CODE_PROFESSION").text
  end

  def test_li_les_champs_dun_contact
    etablissement = Etablissement.create
    identite_eleve = {identifiant: 'XXX', nom: 'Martin', prenom: 'Jean', date_naiss: '1970-01-01'}
    dossier_eleve = cree_dossier_eleve(identite_eleve, etablissement, 'validé')
    dossier_eleve.contact_urgence.update(nom: 'Durant', prenom: 'Philippe', tel_principal: '0123456789', tel_secondaire: '0602020202')
    mappings = []

    doc = Nokogiri::XML(export_xml(etablissement, mappings, 'export_xml_robot'))

    structure = "/IMPORT_ELEVES/DONNEES/ELEVES/ELEVE[1]/CONTACT/"
    assert_equal 'Durant', doc.xpath("#{structure}NOM_DE_FAMILLE").text
    assert_equal 'Philippe', doc.xpath("#{structure}PRENOM").text
    assert_equal '0123456789', doc.xpath("#{structure}TEL_PERSONNEL").text
    assert_equal '0602020202', doc.xpath("#{structure}TEL_PORTABLE").text
  end

  def test_ajoute_les_options_dun_eleve
    etablissement = Etablissement.create
    identite_eleve = {identifiant: 'XXX', nom: 'Martin', prenom: 'Jean', date_naiss: '1970-01-01'}
    dossier_eleve = cree_dossier_eleve(identite_eleve, etablissement, 'validé')
    dossier_eleve.eleve.option << Option.create(nom: "Anglais")
    dossier_eleve.eleve.option << Option.create(nom: "Espagnol")
    mappings = []

    doc = Nokogiri::XML(export_xml(etablissement, mappings, 'export_xml_robot'))
    
    structure = "/IMPORT_ELEVES/DONNEES/ELEVES/ELEVE[1]/SCOLARITE_ACTIVE/OPTIONS/"
    assert_equal 'Anglais', doc.xpath("#{structure}OPTION[1]/CODE_MATIERE").text
    assert_equal 'Espagnol', doc.xpath("#{structure}OPTION[2]/CODE_MATIERE").text
  end

end

class Mapping
  attr_accessor :source, :cible
  def initialize source, cible
    @source = source
    @cible = cible
  end
end
