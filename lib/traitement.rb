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

def genere_pdf eleve
  Prawn::Document.new do
    move_down 30
    float do
      bounding_box([320, cursor], :width => 200) do
        text "#{eleve.dossier_eleve.etablissement.ville}, le #{Time.now.strftime('%e %B %Y')}", :align => :center
        move_down 10
        text "#{eleve.dossier_eleve.etablissement.nom}", :align => :center
        text "#{eleve.dossier_eleve.etablissement.adresse}", :align => :center
        text "#{eleve.dossier_eleve.etablissement.code_postal} #{eleve.dossier_eleve.etablissement.ville}", :align => :center
      end
    end
    text "<b>Inscription au collège</b>", :inline_format => true
    move_down 80
    text "Madame, Monsieur,"
    move_down 30
    text "  Pour que votre enfant #{eleve.prenom} #{eleve.nom} poursuive sa scolarité au collège, veuillez vous munir des pièces suivantes :"
    move_down 10
    float do
      bounding_box([30, cursor], :width => 500) do
        text "  - document 1"
        text "  - document 2"
        text "  - document 3"
        text "  - document 4"
        text "  - document 5"
      end
    end
    move_down 80
    text "Vous pouvez les photographier avec votre téléphone ou les scanner avec votre ordinateur."
    text "Dans les deux cas rendez-vous sur le site avant le #{eleve.dossier_eleve.etablissement.date_limite} :"
    move_down 30
    text "<b>dossiersco.herokuapp.com</b>", :inline_format => true, :align => :center
    move_down 30
    text "Vous entrerez :"
    move_down 10
    float do
      bounding_box([30, cursor], :width => 500) do
        text "  - Identifiant : #{eleve.identifiant}"
        text "  - La date de naissance de l'élève"
      end
    end
    move_down 70
    text "Si vous ne souhaitez pas faire l'inscription en ligne, rendez-vous au collège : #{eleve.dossier_eleve.etablissement.message_permanence}."
  end
end
