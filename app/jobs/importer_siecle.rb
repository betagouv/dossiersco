# frozen_string_literal: true

class ImporterSiecle < ApplicationJob

  queue_as :default

  discard_on(StandardError) do |_job, error|
    ExceptionNotifier.caught(error)
  end

  def perform(tache_id, email)
    tache = TacheImport.find(tache_id)
    tache.update(statut: TacheImport::STATUTS[:en_traitement])

    if tache.import_nomenclature?
      ImportNomenclature.new.perform(tache)
      mail = AgentMailer.succes_import_nomenclature(email)
    elsif tache.import_responsables?
      ImportResponsables.new.perform(tache)
      mail = AgentMailer.succes_import_responsables(email)
    elsif tache.import_eleves?
      ImportEleves.new.perform(tache)
      mail = AgentMailer.succes_import_eleves(email)
    else
      importeur = ImportEleveComplete.new
      importeur.perform(tache)
      mail = AgentMailer.succes_import(email, importeur.statistiques)
    end
    mail.deliver_now

    tache.update(statut: TacheImport::STATUTS[:terminee])
  rescue StandardError => e
    tache.update(statut: TacheImport::STATUTS[:en_erreur])
    AgentMailer.erreur_import(email, e).deliver_now
  end

end
