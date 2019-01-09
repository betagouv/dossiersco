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

def get_fichier_s3 nom_fichier
  if ENV['S3_KEY'].present?
    connection = Fog::Storage.new({
                      provider: 'AWS',
                      aws_access_key_id: ENV['S3_KEY'],
                      aws_secret_access_key: ENV['S3_SECRET'],
                      region: ENV['S3_REGION'],
                      path_style: true # indispensable pour éviter l'erreur "hostname does not match the server certificate"
                  })
    bucket = connection.directories.get('dossierscoweb')
    bucket.files.get("uploads/#{nom_fichier}")
  else
    # On crée un objet qui émule le comportement de l'objet Fog::Storage::AWS::File
    # à savoir une méthode URL avec un paramètre de délai de validité et qui renvoie
    # une URL (en remote) ou un chemin de fichier (en local)
    fichier = Object.new
    fichier.define_singleton_method(:url) do |x|
      "public/uploads/#{nom_fichier}"
    end
    fichier
  end
end