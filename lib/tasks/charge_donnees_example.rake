desc "Charger des données exemple"
task :charger_donnees_exemple => ['db:truncate'] do
  return if Rails.env.production?
  eleves = [
    {prenom: 'Edith',
     nom: 'Piaf',
     date_naiss: '1915-12-19',
     niveau_classe_ant: '6EME',
     classe_ant: '6EME 1',
     nationalite: 'francaise',
     sexe: 'Féminin',
     identifiant: '2'
  },
  {prenom: 'Etienne',
   nom: 'Puydebois',
   date_naiss: '1995-11-19',
   niveau_classe_ant: '4EME',
   classe_ant: '4EME 1',
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
   classe_ant: '4EME 1',
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
  },
  {prenom: 'Laurence',
   nom: 'Hugo',
   niveau_classe_ant: '3EME',
   classe_ant: '3EME 1',
   date_naiss: '1970-01-01',
   nationalite: 'FRANCE',
   sexe: 'Féminin',
   identifiant: '7'
  }
  ]
  eleves.each { |eleve| eleve.update(ville_naiss: 'Paris', pays_naiss: 'France') }

  oeben = Etablissement.create!({
    uai: "0752542F",
    nom: "Jean-Francois Oeben",
    date_limite: "samedi 3 juin 2018",
    adresse: "21 Rue de Reuilly",
    ville: "Paris",
    code_postal: '75012',
    message_permanence: "mercredi 19 juin de 8h à 19h"
  })
  cree_dossier_eleve eleves[1], oeben, 'pas connecté'
  cree_dossier_eleve eleves[6], oeben, 'pas connecté'

  tillion = Etablissement.create!({
    uai: "0753936W",
    nom: "Germaine Tillion",
    date_limite: "samedi 6 juin 2018",
    adresse: "8 Avenue Vincent d'Indy",
    ville: 'Paris',
    code_postal: '75012',
    message_permanence: "lundi 17 et mardi 18 juin de 10h à 20h",
    email: 'etablissement@email.com'
  })

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
  cree_dossier_eleve eleves[4], tillion
  cree_dossier_eleve eleves[5], tillion, 'validé'

  d5 = Eleve.find_by(identifiant: eleves[5][:identifiant]).dossier_eleve
  d5.update(commentaire: "Pas mal", satisfaction: 4, date_signature: Time.now)

  eleve = Eleve.find_by(identifiant: '6')
  montee = Montee.create

  anglais = Option.create(nom: 'anglais', groupe: 'LV1', modalite: 'obligatoire')
  allemand = Option.create(nom: 'allemand', groupe: 'LV1', modalite: 'obligatoire')
  anglais_d = Demandabilite.create montee_id: montee.id, option_id: anglais.id
  allemand_d = Demandabilite.create montee_id: montee.id, option_id: allemand.id
  latin = Option.create(nom: 'latin', groupe: 'LCA', modalite: 'facultative')
  grec = Option.create(nom: 'grec', groupe: 'LCA', modalite: 'facultative')
  latin_d = Demandabilite.create montee_id: montee.id, option_id: latin.id
  grec_d = Demandabilite.create montee_id: montee.id, option_id: grec.id
  eleve.update(montee: montee)
  montee.demandabilite << anglais_d
  montee.demandabilite << allemand_d
  montee.demandabilite << latin_d
  montee.demandabilite << grec_d

  eleve_5eme = Eleve.find_by(identifiant: '5')
  eleve_5eme.option << Option.create(nom: 'latin', groupe: 'LCA', modalite: 'obligatoire')
  eleve_5eme.option << Option.create(nom: 'grec', groupe: 'LCA', modalite: 'obligatoire')

  eleve_4eme = Eleve.find_by(identifiant: '4')
  montee_4eme = Montee.create
  eleve_4eme.update(montee: montee_4eme)
  grec_obligatoire = Option.create(nom: 'grec', groupe: 'LCA', modalite: 'obligatoire')
  grec_obligatoire_d = Demandabilite.create montee_id: montee_4eme.id, option_id: grec_obligatoire.id
  latin = Option.create(nom: 'latin', groupe: 'LCA', modalite: 'facultative')
  latin_d = Abandonnabilite.create montee_id: montee_4eme.id, option_id: latin.id
  eleve_4eme.option << latin
  montee_4eme.demandabilite << grec_obligatoire_d
  montee_4eme.abandonnabilite << latin_d

  Agent.create!(password: '$2a$10$6njb4Rn4RHyFFJpP5QEJGutErgZVOr6/cCM17IKoIsiQDZQABBN2a',
                nom: 'De Maulmont', prenom: 'Pierre', etablissement_id: tillion.id,
                email: 'pierre.de-maulmont@ac-paris.fr', admin: true)
end

def cree_dossier_eleve eleve, etablissement, etat = 'en attente de validation'
  e = Eleve.create!(eleve)
  dossier_eleve = DossierEleve.create!(
    eleve_id: e.id,
    etablissement_id: etablissement.id,
    satisfaction: e.identifiant || 0 % 5,
    etat: etat
  )
  if etat == 'en attente de validation'
    dossier_eleve.update commentaire: 'Très bien', date_signature: Time.now
  end
  RespLegal.create! dossier_eleve_id: dossier_eleve.id,
    lien_de_parente: 'Père', prenom: 'Jean', nom: 'Blayo',
    adresse: '42 rue du départ', code_postal: '75018', ville: 'Paris',
    adresse_ant: '42 rue du départ', code_postal_ant: '75018', ville_ant: 'Paris',
    tel_principal: '0123456789', tel_secondaire: '0602020202', email: 'test2@test.com',
    profession: 'artisan', enfants_a_charge: 2,
    communique_info_parents_eleves: false,
    priorite: 2
  cree_resp_legal dossier_eleve
  cree_contact_urgence dossier_eleve

  dossier_eleve
end

def cree_contact_urgence dossier_eleve
  ContactUrgence.create! dossier_eleve_id: dossier_eleve.id,
    lien_avec_eleve: "Tante", prenom: "Aude", nom: "Daniel", tel_principal: '0103030303'
end

def cree_resp_legal dossier_eleve
  RespLegal.create! dossier_eleve_id: dossier_eleve.id,
    lien_de_parente: 'Mère', prenom: 'Gertrude', nom: 'Martin',
    adresse: '42 rue victoire', code_postal: '75020', ville: 'Paris',
    adresse_ant: '42 rue victoire', code_postal_ant: '75020', ville_ant: 'Paris',
    tel_principal: '0123456789', tel_secondaire: '0987654321', email: 'test@test.com',
    profession: 'concierge', enfants_a_charge: nil,
    communique_info_parents_eleves: true,
    priorite: 1
end

