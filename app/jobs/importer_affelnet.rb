class ImporterAffelnet < ApplicationJob
  queue_as :default

  def perform(tache_id, email)
    begin
      tache = TacheImport.find(tache_id)
      importer_affelnet(tache)

      mail = AgentMailer.succes_import(email, statistiques)
      mail.deliver_now
    rescue
      AgentMailer.erreur_import(email).deliver_now
    end
  end

  def importer_affelnet(tache)

  end
end
