require 'roo'
require 'roo-xls'

class ImporterAffelnet < ApplicationJob
  queue_as :default

  def perform(tache_id, email)
    tache = TacheImport.find(tache_id)
    begin
      tache.update(statut: TacheImport::STATUTS[:en_traitement])
      statistiques = importer_affelnet(tache)
      tache.update(statut: TacheImport::STATUTS[:terminee])
      mail = AgentMailer.succes_import(email, statistiques)
      mail.deliver_now
    rescue Exception => e
      logger.error e
      tache.update(statut: TacheImport::STATUTS[:en_erreur])
      AgentMailer.erreur_import(email).deliver_now
    end
  end

  def importer_affelnet(tache)
    xls_document = Roo::Spreadsheet.open tache.fichier.path
    ligne = (xls_document.first_row + 1..xls_document.last_row)
    nombre_eleves_importes = 0
    ligne.each do |row|
      ligne = xls_document.row(row)
      eleve = Eleve.create!(nom: ligne[0], prenom: ligne[1], date_naiss: ligne[2])
      dossier_eleve = DossierEleve.create!(eleve: eleve, etablissement: tache.etablissement)
      RespLegal.create!(dossier_eleve: dossier_eleve, priorite: 1)
      nombre_eleves_importes += 1
    end
    {portable: 0, email: 0, eleves: nombre_eleves_importes}
  end
end
