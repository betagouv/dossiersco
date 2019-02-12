require 'import_siecle'

class TraiterImportsJob < ApplicationJob
  queue_as :default

  def perform(tache_id, email)
    begin
      tache = TacheImport.find(tache_id)
      statistiques = import_xls tache.fichier.path, tache.etablissement_id
      mail = AgentMailer.succes_import(email, statistiques)
      mail.deliver_now
    rescue
      AgentMailer.erreur_import(email).deliver_now
    end
  end
end
