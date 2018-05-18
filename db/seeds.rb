require_relative '../helpers/models.rb'

beaumarchais = Etablissement.create_with(adresse: "124 Rue Amelot", ville: "Paris", code_postal: "75011",
    message_permanence: "Si vous ne souhaitez pas utiliser cet outils, contacter le secrétariat pour un rendez-vous : ce.0750362l@ac-paris.fr")
    .find_or_create_by(nom: "Collège Beaumarchais")

Agent.create_with(password: "$2a$10$oxnt7Xyj6onJMCWMZGpdv.4dNjM3uqXkF5qNrPgov14rcO0ojbYJ2",
    nom: 'Nadia', prenom: 'Sfoggia', etablissement_id: beaumarchais.id)
    .find_or_create_by(identifiant: 'nsfoggia')

PieceAttendue.create_with(nom: "Justificatif de domicile",
    explication: "Pour justifier d’une nouvelle adresse si l’un des responsables légaux a déménagé depuis la dernière rentrée",
    etablissement_id: beaumarchais.id)
    .find_or_create_by(code: "justificatif_domicile")

Option.create_with(etablissement_id: beaumarchais.id, niveau_debut: 4).find_or_create_by(nom: 'Espagnol débutant')
Option.create_with(etablissement_id: beaumarchais.id, niveau_debut: 4).find_or_create_by(nom: 'Espagnol non débutant')
