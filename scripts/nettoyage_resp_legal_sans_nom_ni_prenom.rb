# frozen_string_literal: true

RespLegal.where(
  nom: [nil, ""],
  prenom: [nil, ""],
  email: [nil, ""],
  tel_personnel: [nil, ""],
  tel_professionnel: [nil, ""],
  tel_portable: [nil, ""],
  adresse: [nil, ""]
).joins(:dossier_eleve).where("dossier_eleves.etat = 'validé'").delete_all
