helpers do
  def get_fichier_s3 nom_fichier
    emplacement_fichier = "uploads/#{nom_fichier}"
    if ENV['S3_KEY'].present?
      connection = Fog::Storage.new({
        provider: 'AWS',
        aws_access_key_id: ENV['S3_KEY'],
        aws_secret_access_key: ENV['S3_SECRET'],
        region: ENV['S3_REGION'],
        path_style: true # indispensable pour éviter l'erreur "hostname does not match the server certificate"
      })
      bucket = connection.directories.get('dossierscoweb')
      bucket.files.get(emplacement_fichier)
    else
      # Pour émuler l'objet "File" de Fog::Storage::AWS, on dote la chaîne
      # "emplacement_fichier" d'une méthode de singleton nommée "url" qui renvoie
      # tout simplement le nom du fichier (donc l'objet "emplacement_fichier" lui-même)
      # cf https://apidock.com/ruby/Object/define_singleton_method
      emplacement_fichier.define_singleton_method(:url) {|x| "public/#{emplacement_fichier}"}
      emplacement_fichier
    end
  end
end
