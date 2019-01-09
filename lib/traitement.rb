require 'import_siecle'

def traiter_imports
  tache = TacheImport.find_by(statut: 'en_attente')
  return unless tache
  tache.traiter
end

def traiter_messages
  message = Message.find_by(etat: 'en_attente')
  return unless message
  message.envoyer
end
