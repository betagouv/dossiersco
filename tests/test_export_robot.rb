ENV['RACK_ENV'] = 'test'

require 'nokogiri'
require 'test/unit'
require 'rack/test'
require 'tempfile'

require_relative '../helpers/singulier_francais'
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
    etablissement = Etablissement.first
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
    valeurs = {identifiant: 'XXX', nom: 'Martin'}
    dossier_eleve = cree_dossier_eleve(valeurs, etablissement)
    mappings = [Mapping.new(:identifiant, 'ID_NATIONAL'),
                Mapping.new(:nom, 'NOM_DE_FAMILLE')]
    doc = Nokogiri::XML(export_xml(etablissement, mappings, 'export_xml_robot'))
    structure = "/IMPORT_ELEVES/DONNEES/ELEVES/ELEVE[1]/"
    mappings.each do |mapping|
      assert_equal valeurs[mapping.source], doc.xpath("#{structure}#{mapping.cible}").text
    end
  end
end

class Mapping
  attr_accessor :source, :cible
  def initialize source, cible
    @source = source
    @cible = cible
  end
end