# frozen_string_literal: true

class PdfConvocation

  attr_accessor :nom

  def initialize(etablissement, classe_des_eleves, dossiers_eleve)
    self.nom = "#{classe_des_eleves}.pdf"
    dossier = "tmp/#{etablissement.id}"
    FileUtils.mkdir_p(dossier) unless File.directory?(dossier)
    Prawn::Document.generate("#{dossier}/#{nom}") do |pdf|
      nombre_de_dossier = 0
      dossiers_eleve.sort_by(&:nom).each do |dossier_eleve|
        nombre_de_dossier += 1
        pdf.default_leading 3
        pdf.move_down 20

        affiche_entete(pdf, etablissement)
        pdf.move_down 20

        affiche_texte(pdf, etablissement, dossier_eleve)
        pdf.move_down 5

        affiche_pieces_attendues(pdf, etablissement)
        pdf.move_down 10

        pdf.text "Pour le bon déroulement de l’inscription en ligne, merci de vous connecter "\
          "et de vérifier les informations vous concernant avant le : #{etablissement.date_limite}", inline_format: true, indent_paragraphs: 20

        pdf.move_down 10
        pdf.text "Votre identifiant est : <b>#{dossier_eleve.eleve.identifiant}</b> ", inline_format: true

        pdf.move_down 10
        pdf.text "Cet outil numérique relève d’une démarche d’innovation ; nous sommes très intéressés par vos retours."
        pdf.text "Si vous ne souhaitez pas réaliser cette démarche par Internet, veuillez prendre contact avec le collège."
        pdf.draw_text etablissement.signataire, at: [250, 90]

        pdf.text_box "Si vous ne souhaitez pas inscrire votre enfant au Collège #{etablissement.nom}, veuillez en " \
          "informer notre secrétariat dans les meilleurs délais. Nous restons à votre disposition " \
          "pour toute question relative à l’inscription.", size: 9, at: [0, 40], width: 530

        pdf.start_new_page if nombre_de_dossier < dossiers_eleve.length
      end
    end
  end

  def affiche_entete(pdf, etablissement)
    pdf.text_box "#{etablissement.ville}, le #{Time.now.strftime('%d/%m/%Y')}", at: [0, pdf.cursor],
                                                                                width: pdf.bounds.width, align: :right

    pdf.text "DossierSCO", size: 20

    pdf.text "Collège #{etablissement.nom}", leading: 5, style: :bold
    pdf.text "#{etablissement.adresse} #{etablissement.code_postal} #{etablissement.ville}", style: :bold

    pdf.move_down 20
    pdf.text "Inscriptions #{Time.now.strftime('%Y')}/#{Time.now.strftime('%Y').to_i + 1}", size: 20, align: :center
  end

  def affiche_texte(pdf, etablissement, dossier)
    pdf.text "Madame, Monsieur,"

    pdf.move_down 10
    pdf.text "Votre enfant <b>#{dossier.eleve.prenom} #{dossier.nom}</b> est affecté(e) au " \
      " Collège #{etablissement.nom}, #{etablissement.ville}.", inline_format: true,
                                                                indent_paragraphs: 20
    pdf.text "Pour procéder à son inscription pour la prochaine année scolaire, nous vous invitons à " \
      "vous connecter, sur un ordinateur de bureau, ordinateur portable, tablette connectée ou " \
      "téléphone connecté, à l’adresse ci-dessous :", inline_format: true

    pdf.move_down 10
    pdf.text "https://dossiersco.fr", size: 16, align: :center

    pdf.move_down 10
    pdf.text "(Pour garantir l’accès le plus rapide au site, merci de saisir cette adresse dans la barre " \
      "d’adresse de votre navigateur en saisissant l’adresse en entier, et non dans la barre " \
      "de recherche)", inline_format: true, indent_paragraphs: 20
    pdf.text "Veuillez vous munir des pièces suivantes ou de leurs photocopies :"
  end

  def affiche_pieces_attendues(pdf, etablissement)
    if etablissement.pieces_attendues.count > 7
      hauteur_debut_colonne = pdf.cursor

      pdf.bounding_box([0, hauteur_debut_colonne], width: (pdf.bounds.width / 2)) do
        etablissement.pieces_attendues[0...7].each do |piece|
          pdf.text "- #{piece.nom}", indent_paragraphs: 20
        end
      end

      pdf.bounding_box([(pdf.bounds.width / 2), hauteur_debut_colonne],
                       width: (pdf.bounds.width / 2),
                       height: 115) do
                         etablissement.pieces_attendues[7...14].each do |piece|
                           pdf.text "- #{piece.nom}", indent_paragraphs: 20
                         end
                       end

    else
      etablissement.pieces_attendues.each do |piece|
        pdf.text "- #{piece.nom}"
      end
    end
  end

end
