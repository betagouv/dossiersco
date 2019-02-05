require 'import_siecle'

class TraiterImportsJob < ApplicationJob
  queue_as :default

  def perform(tache_id)
    tache = TacheImport.find(tache_id)
    statistiques = import_xls tache.fichier.path, tache.etablissement_id
    mail = ImportMailer.succes_import(tache.etablissement.id, statistiques)
    mail.deliver_now
  end
end
