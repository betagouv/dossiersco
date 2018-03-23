def init
  Etablissement.destroy_all
  DossierEleve.destroy_all
  Eleve.destroy_all

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
    date_limite: "2018-06-06"
  })
  DossierEleve.create!(
      eleve_id: eleve.id,
      etablissement_id: etablissement.id,
      demarche: "reinscription"
  )

  eleve = Eleve.create!(eleves[1])
  etablissement = Etablissement.create!({
    nom: "Collège Arago",
    date_limite: "2018-06-03"
  })
  DossierEleve.create!(
      eleve_id: eleve.id,
      etablissement_id: etablissement.id,
      demarche: "reinscription"
  )

end
