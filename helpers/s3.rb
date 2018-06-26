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

  def upload_pieces_jointes dossier_eleve, params, etat='soumis'
    params.each do |code, piece|
      if params[code].present? and params[code]["tempfile"].present?
        file = File.open(params[code]["tempfile"])
        uploader = FichierUploader.new
        uploader.store!(file)
        nom_du_fichier = File.basename(file.path)
        piece_attendue = PieceAttendue.find_by(code: code, etablissement_id: dossier_eleve.etablissement_id)
        piece_jointe = PieceJointe.find_by(piece_attendue_id: piece_attendue.id, dossier_eleve_id: dossier_eleve.id)
        if piece_jointe.present?
          piece_jointe.update(etat: etat, clef: nom_du_fichier)
        else
          piece_jointe = PieceJointe.create!(etat: etat, clef: nom_du_fichier, piece_attendue_id: piece_attendue.id, dossier_eleve_id: dossier_eleve.id)
        end
      end
    end
  end
end
