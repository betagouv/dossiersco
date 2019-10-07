# frozen_string_literal: true

ContactUrgence.where(
  nom: [nil, ""],
  prenom: [nil, ""],
  tel_principal: [nil, ""],
  tel_secondaire: [nil, ""],
).delete_all
