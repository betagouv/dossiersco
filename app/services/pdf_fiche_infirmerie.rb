# frozen_string_literal: true

class PdfFicheInfirmerie

  attr_accessor :nom

  CHAMP_LIBRE = "..............................."

  def initialize(etablissement, classe_des_eleves, dossiers_eleve)
    self.nom = "#{classe_des_eleves}.pdf"
    dossier = "tmp/#{etablissement.id}"
    FileUtils.mkdir_p(dossier) unless File.directory?(dossier)
    Prawn::Document.generate("#{dossier}/#{nom}") do |pdf|
      pdf.font_families.update("LiberationSans" => {
                                 normal: Rails.root.join("public/fonts/liberation_sans/LiberationSans-Regular.ttf"),
                                 italic: Rails.root.join("public/fonts/liberation_sans/LiberationSans-Italic.ttf"),
                                 bold: Rails.root.join("public/fonts/liberation_sans/LiberationSans-Bold.ttf"),
                                 bold_italic: Rails.root.join("app/assets/fonts/LiberationSans-BoldItalic.ttf")
                               })
      pdf.font "LiberationSans" do
        nombre_de_dossier = 0
        dossiers_eleve.each do |dossier_eleve|
          nombre_de_dossier += 1
          pdf.default_leading 7
          pdf.move_down 20

          affiche_etablissement(pdf, etablissement)
          affiche_entete(pdf)
          pdf.move_down 15

          affiche_eleve(pdf, dossier_eleve.eleve)
          pdf.move_down 8

          affiche_les_respresentant_legaux(pdf, dossier_eleve.resp_legal)
          affiche_la_personne_en_cas_urgence(pdf, dossier_eleve.contact_urgence)
          pdf.move_down 8

          affiche_bas_de_page(pdf)
          pdf.start_new_page if nombre_de_dossier < dossiers_eleve.length
        end
      end
      pdf
    end
  end

  def telephone(responsable, type)
    if responsable.send("tel_#{type}").present?
      responsable.send("tel_#{type}")
    else
      CHAMP_LIBRE
    end
  end

  def affiche_les_respresentant_legaux(pdf, representants)
    representants.each do |responsable|
      pdf.text "<b>Responsable légal #{responsable.priorite}</b>" \
        "  Nom : #{responsable.nom}  Prénom : #{responsable.prenom}", inline_format: true
      pdf.text "Lien avec l'élève : #{responsable.lien_de_parente}"
      pdf.text "Adresse : #{responsable.adresse}, #{responsable.code_postal} #{responsable.ville}"
      pdf.text "Tel. Personnel : #{telephone(responsable, :personnel)} ," \
        "    Portable : #{responsable.tel_portable.present? ? responsable.tel_portable : CHAMP_LIBRE}," \
        "     Pro : #{responsable.tel_professionnel.present? ? responsable.tel_professionnel : CHAMP_LIBRE}"
    end

    pdf.move_down 8

    if representants.length < 2
      pdf.text "<b>Responsable légal 2</b>  Nom : #{CHAMP_LIBRE}  Prénom : #{CHAMP_LIBRE}", inline_format: true
      pdf.text "Lien avec l'élève : #{CHAMP_LIBRE}"
      pdf.text "Adresse : #{CHAMP_LIBRE}#{CHAMP_LIBRE}#{CHAMP_LIBRE}"
      pdf.text "Tel. Personnel : #{CHAMP_LIBRE},     Portable : #{CHAMP_LIBRE},     Pro : #{CHAMP_LIBRE}"
      pdf.move_down 8
    end

    pdf.text "Numéro de sécurité sociale du responsable : #{CHAMP_LIBRE}"
    pdf.move_down 8
  end

  def affiche_etablissement(pdf, etablissement)
    pdf.text "Collège #{etablissement.nom}", leading: 0, size: 10
    pdf.text etablissement.adresse.to_s, leading: 0, size: 10
    pdf.text "#{etablissement.code_postal} #{etablissement.ville}", leading: 0, size: 10
  end

  def affiche_la_personne_en_cas_urgence(pdf, contact_urgence)
    pdf.text "Personne à prévenir en cas d'absence des responsables légaux :"
    if contact_urgence.nil?
      pdf.text "Nom : #{CHAMP_LIBRE}  Prénom : #{CHAMP_LIBRE}", inline_format: true
      pdf.text "Lien avec l'élève : #{CHAMP_LIBRE}"
      pdf.text "Tel. Personnel : #{CHAMP_LIBRE},     Portable : #{CHAMP_LIBRE}"
    else
      pdf.text "Nom : #{contact_urgence.nom}" \
        "  Prénom : #{contact_urgence.prenom}", inline_format: true
      pdf.text "Lien avec l'élève : #{contact_urgence.lien_de_parente}"

      pdf.text "Tel. Principal :" \
        " #{telephone(contact_urgence, :principal)}," \
        "     Secondaire : "\
        " #{telephone(contact_urgence, :secondaire)}"
    end
  end

  def affiche_entete(pdf)
    pdf.bounding_box([280, 700], width: 250, height: 50) do
      pdf.text "Année #{Time.now.strftime('%Y')}-#{Time.now.strftime('%Y').to_i + 1}", size: 14, align: :right
    end

    pdf.text "Fiche infirmerie", size: 20, align: :center
  end

  def affiche_eleve(pdf, eleve)
    pdf.text "<b>NOM</b> : #{eleve.nom},    <b>Prénom</b> : #{eleve.prenom}," \
      "    <b>Classe</b> : #{CHAMP_LIBRE}", inline_format: true
    pdf.text "Date de naissance : #{eleve.date_naiss.to_date.strftime('%d/%m/%Y')}" \
      "  Scolarité antérieure :" \
      " #{eleve.classe_ant.present? ? eleve.classe_ant : CHAMP_LIBRE}"
  end

  def affiche_bas_de_page(pdf)
    pdf.text "Assurance scolaire, nom de la compagnie #{CHAMP_LIBRE}, N° de police #{CHAMP_LIBRE}"

    pdf.text "En cas d'urgence, un élève accidenté ou malade est orienté et transporté, par les services de" \
      " secours, vers l'hôpital le plus proche. La famille est immédiatement avertie par nos soins." \
      " Un mineur ne peut sortir de l'hôpital qu'accompagné d'un responsable légal; En cas de" \
      " transport par ambulance privée, les frais sont pris en charge par l'assurance maladie de" \
      " la famille.", leading: 0, align: :justify, size: 10
    pdf.text "Observations particulières que vous jugez utiles de porter à connaissance du service médical" \
      " (allergie, maladie chronique, traitement en cours, précautions" \
      " particulières...)", leading: 0, size: 10
    pdf.move_down 8
    pdf.text ".................................................................................................." \
      ".............................................................................................." \
      ".............................................................................................." \
      ".............................................................................................." \
      ".............................................................................................." \
      "........."

    pdf.text "Si votre enfant bénéficie d'un PAI (projet d'accueil individualisé) pour des troubles de santé" \
      " chroniques, des allergies..., d'un PPS (plan personnalisé de scolarité) ou d'un PAP (plan" \
      " d'accompagnement personnalisé) pour des troubles des apprentissage, veuillez prendre contact" \
      " avec l'infirmier(ère) de l'établissement ou la/le médecin" \
      " scolaire.", leading: 0, size: 10, align: :justify
    pdf.move_down 8
    pdf.text "Date et signature du responsable légal :", size: 10
  end

end
