# frozen_string_literal: true

class ImporterSiecle < ApplicationJob

  queue_as :default

  discard_on(StandardError) do |_job, error|
    ExceptionNotifier.caught(error)
  end

  def perform(tache_id, email)
    tache = TacheImport.find(tache_id)
    tache.update(statut: TacheImport::STATUTS[:en_traitement])

    declenche_import(tache, email)
    tache.update(statut: TacheImport::STATUTS[:terminee])
  rescue StandardError => e
    tache.update(statut: TacheImport::STATUTS[:en_erreur])
    AgentMailer.erreur_import(email, e).deliver_now
  end

  def declenche_import(tache, email)
    file = "#{Rails.root}/public/#{tache.fichier}"
    if file_type_xml?(file)
      send("import_fichier_#{tache.type_fichier}", tache, email).deliver_now
    elsif file_type_excel?(file)
      importeur = ImportEleveComplete.new
      importeur.perform(tache)
      AgentMailer.succes_import(email, importeur.statistiques).deliver_now
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
