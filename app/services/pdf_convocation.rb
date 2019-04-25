class PdfConvocation
  attr_accessor :nom

  def initialize(etablissement, classe_des_eleves, dossiers_eleve)
    self.nom = "#{classe_des_eleves}.pdf"
    dossier = "#{Rails.root}/tmp/pdf/#{etablissement.nom}"
    FileUtils.mkdir_p(dossier) unless File.directory?(dossier)
    Prawn::Document.generate("#{dossier}/#{self.nom}")  do |pdf|
      nombre_de_dossier = 0
      dossiers_eleve.each do |dossier_eleve|
        nombre_de_dossier += 1
        pdf.default_leading 3
        pdf.move_down 20
        pdf.text 'DossierSCO', :size => 20

        pdf.bounding_box([280, 700], :width => 250, :height => 100) do
          pdf.text "#{etablissement.ville}, le #{Time.now.strftime('%d/%m/%Y')}", :leading => 5, :align => :right
          pdf.text "#{etablissement.signataire} du collège #{etablissement.nom}", :leading => 5, :align => :right
          pdf.text "#{etablissement.adresse} #{etablissement.code_postal} #{etablissement.ville}", :align => :right
        end

        pdf.move_down 20
        pdf.text "Inscriptions #{Time.now.strftime('%Y')}/#{Time.now.strftime('%Y').to_i + 1}", :size => 20, :align => :center

        pdf.move_down 20
        pdf.text "Madame, Monsieur,"

        pdf.move_down 10
        pdf.text "Votre enfant <b>#{dossier_eleve.eleve.prenom} #{dossier_eleve.eleve.nom}</b> est actuellement " +
                     "inscrit au Collège #{etablissement.nom}, #{etablissement.ville}.", :inline_format => true,
                 :indent_paragraphs => 20
        pdf.text "Pour compléter et valider sa réinscription pour la prochaine année scolaire, nous vous invitons à " +
                     "vous connecter, sur un ordinateur de bureau, ordinateur portable, tablette connectée ou " +
                     "téléphone connecté, à l’adresse ci-dessous :", :inline_format => true

        pdf.move_down 15
        pdf.text "https://dossiersco.fr", :size => 16, :align => :center

        pdf.move_down 15
        pdf.text "(Pour garantir l’accès le plus rapide au site, merci de saisir cette adresse dans la barre " +
                     "d’adresse de votre navigateur en saisissant l’adresse en entier, et non dans la barre " +
                     "de recherche)", :inline_format => true, :indent_paragraphs => 20
        pdf.text "Veuillez vous munir des pièces suivantes ou de leurs photocopies :"

        pdf.move_down 10

        etablissement.pieces_attendues.each do |piece|
          pdf.text "- #{piece.nom}", :indent_paragraphs => 20
        end

        pdf.move_down 10
        pdf.text "Pour le bon déroulement de l’inscription en ligne, merci de vous connecter et de vérifier les " +
                     "informations vous concernant avant le : #{etablissement.date_limite}", :inline_format => true,
                 :indent_paragraphs => 20

        pdf.move_down 10
        pdf.text "Votre identifiant est : <b>#{dossier_eleve.eleve.identifiant}</b> ", :inline_format => true

        pdf.move_down 10
        pdf.text "En réalisant la démarche en ligne vous n’avez pas à nous remettre le dossier papier.", :style => :bold,
                 :indent_paragraphs => 20
        pdf.text "Cet outil numérique relève d’une démarche d’innovation ; nous sommes très intéressés par vos retours."
        pdf.text "Si vous ne souhaitez pas réaliser cette démarche par Internet, veuillez prendre contact avec le collège."
        pdf.draw_text etablissement.signataire, :at => [250, 90]

        pdf.text_box "Si vous ne souhaitez pas inscrire votre enfant au Collège #{etablissement.nom}, veuillez en " +
                         "informer notre secrétariat dans les meilleurs délais. Nous restons à votre disposition " +
                         "pour toute question relative à l’inscription.", :size => 9, :at => [0, 40], :width => 530

        if nombre_de_dossier < dossiers_eleve.length
          pdf.start_new_page
        end
      end
    end
  end
end
