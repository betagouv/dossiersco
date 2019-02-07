require 'import_siecle'

class TraiterImportsJob < ApplicationJob
  queue_as :default

  def perform(tache_id, email)
    tache = TacheImport.find(tache_id)
    statistiques = import_xls tache.fichier.path, tache.etablissement_id
    mail = AgentMailer.succes_import(email, statistiques)
    mail.deliver_now
  end
end
