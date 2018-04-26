helpers do
  def get_fichier_s3 nom_fichier
    if ENV['S3_KEY'].present?
      connection = Fog::Storage.new({
        provider: 'AWS',
        aws_access_key_id: ENV['S3_KEY'],
        aws_secret_access_key: ENV['S3_SECRET'],
        region: ENV['S3_REGION']
      })
      bucket = connection.directories.new(key: 'dossierscoweb')
      bucket.files.get(nom_fichier)
    end
  end
end