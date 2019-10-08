# frozen_string_literal: true

class ImporterSiecle < ApplicationJob

  queue_as :default

  discard_on(StandardError) do |_job, error|
    ExceptionNotifier.caught(error)
  end

  def perform(tache_id, email)
    tache = TacheImport.find(tache_id)
    tache.update(statut: TacheImport::STATUTS[:en_traitement])

    type = %i[import_nomenclature? import_responsables? import_eleves?].detect { |m| tache.send(m) }
    raise StandardError, "type d'import non couvert" if type.nil?

    ImportNomenclature.new.perform(tache)
    AgentMailer.send("succes_#{type.to_s[0..-2]}", email).deliver_now
    tache.update(statut: TacheImport::STATUTS[:terminee])
  rescue StandardError => e
    tache.update(statut: TacheImport::STATUTS[:en_erreur])
    AgentMailer.erreur_import(email, e).deliver_now
  end

end
