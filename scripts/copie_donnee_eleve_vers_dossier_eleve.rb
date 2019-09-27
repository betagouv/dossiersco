# frozen_string_literal: true

DossierEleve.all.joins(:eleve).each do |dossier|
  dossier.update(
    prenom: dossier.eleve.prenom,
    identifiant: dossier.eleve.identifiant,
    nom: dossier.eleve.nom,
    sexe: dossier.eleve.sexe,
    ville_naiss: dossier.eleve.ville_naiss,
    nationalite: dossier.eleve.nationalite,
    classe_ant: dossier.eleve.classe_ant,
    date_naiss: dossier.eleve.date_naiss,
    pays_naiss: dossier.eleve.pays_naiss,
    niveau_classe_ant: dossier.eleve.niveau_classe_ant,
    prenom_2: dossier.eleve.prenom_2,
    prenom_3: dossier.eleve.prenom_3,
    commune_insee_naissance: dossier.eleve.commune_insee_naissance,
    id_prv_ele: dossier.eleve.id_prv_ele
  )
end
