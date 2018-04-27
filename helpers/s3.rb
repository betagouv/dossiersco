helpers do
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
    end
  end
end