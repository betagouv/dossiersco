def init
  Etablissement.destroy_all
  DossierEleve.destroy_all
  Eleve.destroy_all
  Agent.destroy_all
  RespLegal.destroy_all

  eleves = [
      {prenom: 'Edith',
       nom: 'Piaf',
       date_naiss: '1915-12-19',
       niveau_classe_ant: '6EME',
       nationalite: 'francaise',
       identifiant: '2'
      },
      {prenom: 'Etienne',
       nom: 'Puydebois',
       date_naiss: '1995-11-19',
       nationalite: 'francaise',
       identifiant: '1'
      },
      {prenom: 'Philippe',
       nom: 'Blayo',
       niveau_classe_ant: '5EME SECTION SPORTIVE',
       classe_ant: '5EME 1',
       date_naiss: '1970-01-01',
       nationalite: 'FRANCE',
       identifiant: '3'
      },
      {prenom: 'Pierre',
       nom: 'Blayo',
       niveau_classe_ant: '4EME ULIS',
       date_naiss: '1970-01-01',
       nationalite: 'FRANCE',
       identifiant: '4'
      },
      {prenom: 'Eugène',
       nom: 'Blayo',
       niveau_classe_ant: '5EME',
       classe_ant: '5EME 1',
       date_naiss: '1970-01-01',
       nationalite: 'FRANCE',
       identifiant: '5'
      },
      {prenom: 'Emile',
       nom: 'Blayo',
       niveau_classe_ant: '6EME',
       classe_ant: '6EME 1',
       date_naiss: '1970-01-01',
       nationalite: 'FRANCE',
       identifiant: '6'
      }
  ]

  etablissement = Etablissement.create!({
     nom: "College Jean-Francois Oeben",
     date_limite: "samedi 3 juin 2018"})
  cree_dossier_eleve eleves[1], etablissement, 'pas connecté'

  Agent.create!(password: '$2a$10$6njb4Rn4RHyFFJpP5QEJGutErgZVOr6/cCM17IKoIsiQDZQABBN2a',
                nom: 'César', prenom: 'Jules', etablissement_id: etablissement.id,
                identifiant: 'jules')

  etablissement = Etablissement.create!({
      nom: "Collège Germaine Tillion",
      date_limite: "samedi 6 juin 2018"
  })

  cree_dossier_eleve eleves[0], etablissement, 'pas connecté'
  cree_dossier_eleve eleves[2], etablissement, 'pas connecté'
  cree_dossier_eleve eleves[3], etablissement, 'connecté'
  cree_dossier_eleve eleves[4], etablissement, 'en attente de validation'
  cree_dossier_eleve eleves[5], etablissement, 'validé'

  Agent.create!(password: '$2a$10$6njb4Rn4RHyFFJpP5QEJGutErgZVOr6/cCM17IKoIsiQDZQABBN2a',
                nom: 'De Maulmont', prenom: 'Pierre', etablissement_id: etablissement.id,
                identifiant: 'pierre')
end

def cree_dossier_eleve eleve, etablissement, etat
  e = Eleve.create!(eleve)
  DossierEleve.create!(
      eleve_id: e.id,
      etablissement_id: etablissement.id,
      demarche: "reinscription",
      etat: etat,
      etat_photo_identite: "absente",
      etat_assurance_scolaire: "absente",
      etat_jugement_garde_enfant: "absente"
  )
end