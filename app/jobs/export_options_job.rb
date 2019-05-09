# enccoding: UTF-8
# frozen_string_literal: true

class ExportOptionsJob < ActiveJob::Base

  def perform(agent)
    @lignes = faire_lignes(agent)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Export-options") do |sheet|
        sheet.add_row @entete
        @lignes.each { |ligne| sheet.add_row ligne }
      end
      p.serialize("tmp/eleves-par-option-#{agent.etablissement.id}.xlsx")
    end

    mailer = AgentMailer.export_options(agent, File.read("tmp/eleves-par-option-#{agent.etablissement.id}.xlsx"))
    mailer.deliver_now
    FileUtils.rm_rf("tmp/eleves-par-option-#{agent.etablissement.id}.xlsx")
  end

  def faire_lignes(agent)
    options_etablissement = agent.etablissement.options_pedagogiques
    entet_options = options_etablissement.map(&:nom)
    @entete = ["classe actuelle", "MEF actuel", "prenom", "nom", "date naissance", "sexe"].concat(entet_options)
    @lignes = []
    DossierEleve.where(etablissement: agent.etablissement).each do |dossier|
      options_eleve = []
      options_etablissement.each do |option|
        options_eleve << (dossier.options_pedagogiques.include?(option) ? "X" : "")
      end
      mef_origin = dossier.mef_origine.present? ? dossier.mef_origine.libelle : ""
      @lignes << [dossier.eleve.classe_ant, mef_origin, dossier.eleve.prenom, dossier.eleve.nom,
                  dossier.eleve.date_naiss, dossier.eleve.sexe].concat(options_eleve)
    end
    @lignes
  end

end
