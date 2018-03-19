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

eleves.each do |u|
  eleve = Eleve.create!(u)
  DossierEleve.create!(
      eleve_id: eleve.id,
      demarche: "reinscription"
  )
  p "eleve #{eleve.id}"
end
