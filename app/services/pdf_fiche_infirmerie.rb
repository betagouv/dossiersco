# frozen_string_literal: true

class PdfFicheInfirmerie

  attr_accessor :nom

  def initialize(etablissement, classe_des_eleves, dossiers_eleve)
    self.nom = "#{classe_des_eleves}.pdf"
    dossier = "tmp/#{etablissement.id}"
    champ_libre = "..............................."
    FileUtils.mkdir_p(dossier) unless File.directory?(dossier)
    Prawn::Document.generate("#{dossier}/#{nom}") do |pdf|
      nombre_de_dossier = 0
      dossiers_eleve.each do |dossier_eleve|
        nombre_de_dossier += 1
        pdf.default_leading 7
        pdf.move_down 20
        pdf.text "Collège #{etablissement.nom}", leading: 0, size: 10
        pdf.text etablissement.adresse.to_s, leading: 0, size: 10
        pdf.text "#{etablissement.code_postal} #{etablissement.ville}", leading: 0, size: 10

        pdf.bounding_box([280, 700], width: 250, height: 50) do
          pdf.text "Année #{Time.now.strftime('%Y')}-#{Time.now.strftime('%Y').to_i + 1}", size: 14, align: :right
        end
        pdf.text "Fiche infirmerie", size: 20, align: :center
        pdf.move_down 15

        pdf.text "<b>NOM</b> : #{dossier_eleve.eleve.nom},    <b>Prénom</b> : #{dossier_eleve.eleve.prenom}," \
                 "    <b>Classe</b> : #{champ_libre}", inline_format: true
        pdf.text "Date de naissance : #{dossier_eleve.eleve.date_naiss.to_date.strftime('%d/%m/%Y')}" \
                 "  Scolarité antérieure :" \
                 " #{dossier_eleve.eleve.classe_ant.present? ? dossier_eleve.eleve.classe_ant : champ_libre}"
        pdf.move_down 8

        dossier_eleve.resp_legal.each do |responsable|
          pdf.text "<b>Responsable légal #{responsable.priorite}</b>" \
                   "  Nom : #{responsable.nom}  Prénom : #{responsable.prenom}", inline_format: true
          pdf.text "Lien avec l'élève : #{responsable.lien_de_parente}"
          pdf.text "Adresse : #{responsable.adresse}, #{responsable.code_postal} #{responsable.ville}"
          pdf.text "Tel. Personnel : #{responsable.tel_personnel.present? ? responsable.tel_personnel : champ_libre}," \
                   "    Portable : #{responsable.tel_portable.present? ? responsable.tel_portable : champ_libre}," \
                   "     Pro : #{responsable.tel_professionnel.present? ? responsable.tel_professionnel : champ_libre}"
        end
        pdf.move_down 8

        if dossier_eleve.resp_legal.length < 2
          pdf.text "<b>Responsable légal 2</b>  Nom : #{champ_libre}  Prénom : #{champ_libre}", inline_format: true
          pdf.text "Lien avec l'élève : #{champ_libre}"
          pdf.text "Adresse : #{champ_libre}#{champ_libre}#{champ_libre}"
          pdf.text "Tel. Personnel : #{champ_libre},     Portable : #{champ_libre},     Pro : #{champ_libre}"
          pdf.move_down 8
        end

        pdf.text "Numéro de sécurité sociale du responsable : #{champ_libre}"
        pdf.move_down 8

        pdf.text "Personne à prévenir en cas d'absence des responsables légaux :"
        if dossier_eleve.contact_urgence.nil?
          pdf.text "Nom : #{champ_libre}  Prénom : #{champ_libre}", inline_format: true
          pdf.text "Lien avec l'élève : #{champ_libre}"
          pdf.text "Tel. Personnel : #{champ_libre},     Portable : #{champ_libre}"
        else
          pdf.text "Nom : #{dossier_eleve.contact_urgence.nom}" \
                   "  Prénom : #{dossier_eleve.contact_urgence.prenom}", inline_format: true
          pdf.text "Lien avec l'élève : #{dossier_eleve.contact_urgence.lien_avec_eleve}"
          pdf.text "Tel. Principal :" \
                   " #{dossier_eleve.contact_urgence.tel_principal.present? ? dossier_eleve.contact_urgence.tel_principal : champ_libre}," \
                   "     Secondaire : #{dossier_eleve.contact_urgence.tel_secondaire.present? ? dossier_eleve.contact_urgence.tel_secondaire : champ_libre}"
        end
        pdf.move_down 8

        pdf.text "Assurance scolaire, nom de la compagnie #{champ_libre}, N° de police #{champ_libre}"

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

        pdf.start_new_page if nombre_de_dossier < dossiers_eleve.length
      end
    end
  end

end
