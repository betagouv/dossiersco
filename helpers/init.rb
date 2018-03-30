def init
  Etablissement.destroy_all
  DossierEleve.destroy_all
  Eleve.destroy_all
  Agent.destroy_all

  eleves = [
      {prenom: 'Edith',
       nom: 'Piaf',
       date_naiss: '1915-12-19',
       nationalite: 'francaise',
       identifiant: '2'},
      {prenom: 'Etienne',
       nom: 'Puydebois',
       date_naiss: '1995-11-19',
       nationalite: 'francaise',
       identifiant: '1'}
  ]

  eleve = Eleve.create!(eleves[0])
  etablissement = Etablissement.create!({
    nom: "Collège Germaine Thillon",
    date_limite: "samedi 6 juin 2018"
  })
  DossierEleve.create!(
      eleve_id: eleve.id,
      etablissement_id: etablissement.id,
      demarche: "reinscription"
  )

  eleve = Eleve.create!(eleves[1])
  etablissement = Etablissement.create!({
     nom: "College Jean-Francois Oeben",
     date_limite: "samedi 3 juin 2018"})
  DossierEleve.create!(
      eleve_id: eleve.id,
      etablissement_id: etablissement.id,
      demarche: "reinscription"
  )

  etablissement = Etablissement.create!({
      nom: "Arago",
      date_limite: "samedi 6 juin 2018"
  })
  Agent.create!(password: '$2a$10$6njb4Rn4RHyFFJpP5QEJGutErgZVOr6/cCM17IKoIsiQDZQABBN2a',
                nom: 'De Maulmont', prenom: 'Pierre', etablissement_id: etablissement.id,
                identifiant: 'pierre')
end
