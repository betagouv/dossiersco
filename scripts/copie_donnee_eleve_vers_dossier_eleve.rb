# frozen_string_literal: true

DossierEleve.all.each do |dossier|
  eleve = Eleve.find(dossier.eleve_id)
  dossier.update(
    prenom: eleve.prenom,
    identifiant: eleve.identifiant,
    nom: eleve.nom,
    sexe: eleve.sexe,
    ville_naiss: eleve.ville_naiss,
    nationalite: eleve.nationalite,
    classe_ant: eleve.classe_ant,
    date_naiss: eleve.date_naiss,
    pays_naiss: eleve.pays_naiss,
    niveau_classe_ant: eleve.niveau_classe_ant,
    prenom_2: eleve.prenom_2,
    prenom_3: eleve.prenom_3,
    commune_insee_naissance: eleve.commune_insee_naissance,
    id_prv_ele: eleve.id_prv_ele
  )
end
