def init
  RespLegal.destroy_all
  ContactUrgence.destroy_all
  DossierEleve.destroy_all
  Option.destroy_all
  Eleve.destroy_all
  Agent.destroy_all
  PieceAttendue.destroy_all
  PieceJointe.destroy_all
  TacheImport.destroy_all
  Etablissement.destroy_all

  eleves = [
      {prenom: 'Edith',
       nom: 'Piaf',
       date_naiss: '1915-12-19',
       niveau_classe_ant: '6EME',
       nationalite: 'francaise',
       sexe: 'Féminin',
       identifiant: '2'
      },
      {prenom: 'Etienne',
       nom: 'Puydebois',
       date_naiss: '1995-11-19',
       niveau_classe_ant: '4EME',
       nationalite: 'francaise',
       sexe: 'Masculin',
       identifiant: '1'
      },
      {prenom: 'Philippe',
       nom: 'Blayo',
       niveau_classe_ant: '3EME SECTION SPORTIVE',
       classe_ant: '3EME 1',
       date_naiss: '1970-01-01',
       nationalite: 'FRANCE',
       sexe: 'Masculin',
       identifiant: '3'
      },
      {prenom: 'Pierre',
       nom: 'Blayo',
       niveau_classe_ant: '4EME ULIS',
       date_naiss: '1970-01-01',
       nationalite: 'FRANCE',
       sexe: 'Masculin',
       identifiant: '4'
      },
      {prenom: 'Eugène',
       nom: 'Blayo',
       niveau_classe_ant: '5EME',
       classe_ant: '5EME 1',
       date_naiss: '1970-01-01',
       nationalite: 'FRANCE',
       sexe: 'Masculin',
       identifiant: '5'
      },
      {prenom: 'Emile',
       nom: 'Blayo',
       niveau_classe_ant: '6EME',
       classe_ant: '6EME 1',
       date_naiss: '1970-01-01',
       nationalite: 'FRANCE',
       sexe: 'Masculin',
       identifiant: '6'
      }
  ]

  oeben = Etablissement.create!({
     nom: "College Jean-Francois Oeben",
     date_limite: "samedi 3 juin 2018",
     adresse: "21 Rue de Reuilly",
     ville: "Paris",
     code_postal: '75012',
     message_permanence: "mercredi 19 juin de 8h à 19h"
  })
  cree_dossier_eleve eleves[1], oeben, 'pas connecté'

  Agent.create!(password: '$2a$10$6njb4Rn4RHyFFJpP5QEJGutErgZVOr6/cCM17IKoIsiQDZQABBN2a',
                nom: 'César', prenom: 'Jules', etablissement_id: oeben.id,
                identifiant: 'jules')

  tillion = Etablissement.create!({
      nom: "Collège Germaine Tillion",
      date_limite: "samedi 6 juin 2018",
      adresse: "8 Avenue Vincent d'Indy",
      ville: 'Paris',
      code_postal: '75012',
      message_permanence: "lundi 17 et mardi 18 juin de 10h à 20h"
  })

  Option.create!(etablissement_id: tillion.id, nom: 'Espagnol', niveau_debut: 5,
  obligatoire: true, groupe: 'Langue vivante 2')
  Option.create!(etablissement_id: tillion.id, nom: 'Allemand', niveau_debut: 5,
  obligatoire: true, groupe: 'Langue vivante 2')
  Option.create!(etablissement_id: tillion.id, nom: 'Latin', niveau_debut: 5, groupe: 'Langues anciennes')
  Option.create!(etablissement_id: tillion.id, nom: 'Grec', niveau_debut: 5, groupe: 'Langues anciennes')

  PieceAttendue.create!(nom: "Assurance scolaire", code: "assurance_scolaire",
    explication: "assurance de l'éleve 2018/2019", etablissement_id: tillion.id)
  quotien_familial = PieceAttendue.create!(
       nom: "Quotien familial",
       code: "quotien_familial",
       explication: "Pour déterminer le tarif du restaurant",
       etablissement_id: tillion.id)

  cree_dossier_eleve eleves[0], tillion, 'pas connecté'
  cree_dossier_eleve eleves[2], tillion, 'pas connecté'
  cree_dossier_eleve eleves[3], tillion, 'connecté'
  cree_dossier_eleve eleves[4], tillion, 'en attente de validation'
  cree_dossier_eleve eleves[5], tillion, 'validé'

  Agent.create!(password: '$2a$10$6njb4Rn4RHyFFJpP5QEJGutErgZVOr6/cCM17IKoIsiQDZQABBN2a',
                nom: 'De Maulmont', prenom: 'Pierre', etablissement_id: tillion.id,
                identifiant: 'pierre')
end

def cree_dossier_eleve eleve, etablissement, etat
  e = Eleve.create!(eleve)
  dossier_eleve = DossierEleve.create!(
      eleve_id: e.id,
      etablissement_id: etablissement.id,
      demarche: "reinscription",
      etat: etat
      )
  RespLegal.create!(dossier_eleve_id: dossier_eleve.id,
    lien_de_parente: 'Mère', prenom: 'Gertrude', nom: 'Martin',
    adresse: '42 rue de la fin', code_postal: '75020', ville: 'Paris',
    tel_principal: '0123456789', tel_secondaire: '0987654321', email: 'gertrude.martin@email.com',
    situation_emploi: 'Employé', profession: 'concierge', enfants_a_charge: 3,
    enfants_a_charge_secondaire: 2, communique_info_parents_eleves: true,
    priorite: 1)
  RespLegal.create!(dossier_eleve_id: dossier_eleve.id,
    lien_de_parente: 'Père', prenom: 'Jean', nom: 'Blayo',
    adresse: '42 rue du départ', code_postal: '75018', ville: 'Paris',
    tel_principal: '0123456789', tel_secondaire: '', email: 'jean.martin@email.com',
    situation_emploi: 'Employé', profession: 'banque', enfants_a_charge: 2,
    enfants_a_charge_secondaire: 2, communique_info_parents_eleves: false,
    priorite: 2)
end
