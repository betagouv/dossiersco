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
       identifiant: '1'},
      {date_naiss: '2005-10-19',
       nationalite: 'FRANCE',
       identifiant: '080788316HE',
       sexe: 'Féminin',
       ville_naiss: 'PARIS',
       classe_ant: '5ème',
       ets_ant: 'College Jean-Francois Oeben',
       lv2: 'Allemand'
      }
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
    nom: "Collège Arago",
    date_limite: "samedi 3 juin 2018"
  })
  DossierEleve.create!(
      eleve_id: eleve.id,
      etablissement_id: etablissement.id,
      demarche: "reinscription"
  )


	eleve = Eleve.create!(eleves[2])
	etablissement = Etablissement.create!({
    nom: "College Jean-Francois Oeben",
    date_limite: "samedi 3 juin 2018"
	})
	dossier_eleve = DossierEleve.create!(
			eleve_id: eleve.id,
			etablissement_id: etablissement.id,
			demarche: "reinscription"
	)
	RespLegal.create!(
      dossier_eleve_id: dossier_eleve.id,
      lien_de_parente: 'Mère',
      situation_emploi: '',
      profession: '',
      priorite: 1
	)
  RespLegal.create!(
      dossier_eleve_id: dossier_eleve.id,
      lien_de_parente: 'Père',
      email: '',
      situation_emploi: '',
      profession: '',
      priorite: 2
  )
  RespLegal.create!(
      dossier_eleve_id: dossier_eleve.id
  )
end
