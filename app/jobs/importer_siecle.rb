# frozen_string_literal: true

require "zip"

class ImporterSiecle < ApplicationJob

  queue_as :default

  discard_on(StandardError) do |_job, error|
    ExceptionNotifier.caught(error)
  end

  def perform(tache_id, email)
    tache = TacheImport.find(tache_id)
    tache.update(statut: TacheImport::STATUTS[:en_traitement])

    file = "#{Rails.root}/public/#{tache.fichier}"

    if file_type_zip?(file)
      Zip::File.open(file) do |zipfile|
        zipfile.each do |file_entry|
          path = file_entry.zipfile.split("/")[0..-2].join("/")
          declenche_import("#{path}/#{file_entry}", tache, email)
        end
      end
    else
      declenche_import(file, tache, email)
    end

    tache.update(statut: TacheImport::STATUTS[:terminee])
  rescue StandardError => e
    logger.debug e
    tache.update(statut: TacheImport::STATUTS[:en_erreur])
    AgentMailer.erreur_import(email).deliver_now
  end

  def declenche_import(file, tache, email)
    if file_type_xml?(file)
      mail = send("import_fichier_#{tache.type_fichier}", tache, email)
      mail.deliver_now
    elsif file_type_excel?(file)
      importeur = ImportEleveComplete.new
      importeur.perform(tache)
      mail = AgentMailer.succes_import(email, importeur.statistiques)
      mail.deliver_now
    else
      raise StandardError, "type de fichier non reconnu"
    end
  end

  def file_type_excel?(file)
    file_type(file) == "application/vnd.ms-excel"
  end

  def file_type_xml?(file)
    file_type(file) == "text/xml"
  end

  def file_type_zip?(file)
    file_type(file) == "application/zip"
  end

  def file_type(file)
    `file -ib #{file}`.delete("\n").split(";")[0]
  end

  def import_fichier_nomenclature(tache, email)
    ImportNomenclature.new.perform(tache)
    AgentMailer.succes_import_nomenclature(email)
  end

  def import_fichier_responsables(tache, email)
    ImportResponsables.new.perform(tache)
    AgentMailer.succes_import_responsables(email)
  end

  def import_fichier_eleves(tache, email)
    ImportEleves.new.perform(tache)
    AgentMailer.succes_import_eleves(email)
  end

end
