## Jeudi 25 juillet

- **Retour dans SIECLE : inclus DATE_DEB_SCO dans l'année scolaire à venir**

- **Retour dans SIECLE : renseigne l'INE dans la balise ID_NATIONAL**

Des tests d'import nous ont montrés que positionner l'INE dans l'ID_NATIONAL permet la reconnaissance des élèves dans l'import privé.

## Lundi 8 juillet

- **Nettoyer les données sur les pays**

Les zones de saisies des pays sont en texte libre. Pour avoir une cohérence avec SIECLE, nous avons modifié ces zones pour que ce soit un choix dans une liste de pays.

SIECLE enregistre un code sur 3 chiffres, nous faisons de même maintenant, avec un fichier de correspondance entre un pays et un code. Sont concerné le pays de résidence d'un representant légal, le pays de naisssance d'un élève et la nationalité d'un élève.

Toutes les données de la base de production ont été nettoyé pour correspondre au nouveau format (un code au lieu d'un texte libre). Il y a un document qui retrace les cas particulier que nous avons eu à gérer sur [dossiersco/doc/nettoyage_des_pays_et_nationalite.md](https://gitlab.com/dossiersco/dossiersco/blob/master/doc/nettoyage_des_code_pays_et_nationalite.md)

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/673)

- **Retour SIECLE, prendre en compte les code pays et nationalite**

Dans l'export SIECLE, on peut maintenant prendre en compte les code pays des représentant légaux et des élèves.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/679)

---
## Mardi 2 juillet

- **En tant que secrétaire, je reste au même endroit après validation d'une pièce jointe**

Quand on valide les pièces jointes, la page reste au même endroit, sur la pièce jointe qui viens d'être validée.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/643)


- **Conditionner le formulaire de famille**

En tant que famille, en général, je n'ai pas besoin de changer mes informations personnels. J'aimerais avoir une page plus compact pour parcourir mes informations d'un coup d'oeil.

Affiche les informations des représentant légaux en texte avec un bouton pour demander à changer, ce qui affiche un formulaire pour changer les coordonnées d'un des responsables légaux.

Resterais, dans la situation actuelle, à saisir la profession et le nombre d'enfants à charge.


[ticket](https://gitlab.com/dossiersco/dossiersco/issues/616)

---
## lundi 1er juillet

- **afficher le régime de demi-pension dans l'export excel des dossiers**

Affiche le régime de demi-pension dans l'export excel des dossiers

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/668)

---

## dimanche 30 juin

- **Importer la nomenclature**

Afin de pouvoir disposer du code_mef (nécessaire dans le fichier xml de retour de données dans SIECLE), nous avons besoin d'importer le fichier XML de nomenclature.

L'objectif, dans un premier temps, sera de parcourir se fichier, et, pour chaque MEF que nous avons déjà, récupérer le code qui correspond.

⚠ le code mef est millésimé, il faudra donc avoir un fichier de nomenclature de l'année en préparation. Ça sera peut-être à préciser dans le bloc permettant l'import.
💡 trouver une ou deux personnes qui sont prête à faire des tests avec leurs fichiers (peut-être Boris Vian ?)

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/663)

- **Exporter une petite liste d'élèves dans le fichier siecle**

Exporter une liste de un à plusieurs élèves à partir de leur INE.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/666)

---

## Vendredi 28 juin

- Ajouter l'adresse dans l'import xml vers siecle
- Crée un xsd qui évite l'erreur silencieuse du CODE_PARENTE sur un seul chiffre

---

## Jeudi 26 juin

- **Afficher les dates de validation**

Afin de tracer les informations et les grandes étapes d'un dossier,

Affiche dans le dossier la date de validation de la familles,
Affiche dans le dossier la date de validation de l'agent.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/657)

- **Modifier les données de dossiers coté agent**

Les agents peuvent maintenant modifier les données d'adresse et certaines autres d'un dossier, directement dans leur interface.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/661)

---

## Mercredi 26 juin

- **Limiter la possibilité de valider**

Affiche le bouton de validation coté agent, uniquement quand les familles on validé.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/658)

---

## Mardi 25 juin

- **Totaliser le total des collèges en haut de la page suivi**

Afficher la somme total des établissements dans la page de suivi de dossiersco

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/659)

---
## Vendredi 21 juin

- **Valider les adresse emails saisies**

Pour s'assurer que les emails sont bien saisie, nous avons ajouter des validations sur le format des emails.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/653)


- **Amélioration de la page de suivi**

Changements proposés : Avoir des listes exclusives (un collège saute de l'une à l'autre, sans doublon) Afficher un total général des collèges expérimentateurs (inscrits + expérimentateur + utilisateur) fusion des listes 2 et 3 ; modification du wording de toutes

- "Etablissements inscrits (x)"
- "Etablissements expérimentateurs : DossierSCO paramétré ; Elèves importés (y) "
- "Etablissements utilisateurs : ayant ouvert DossierSCO aux familles (Z)" : détail des établissements (z)

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/652)

---
## Mercredi 19 juin

- **Indique comment envoyer un fichier d'import en erreur**

Un fichier en erreur peut être déposé sur https://send.firefox.com et le lien ainsi généré envoyé à l'équipe.

---
## Mardi 18 juin

- **Révision du message de convocation**

En tant que parent d'élève entrant en 6ème, je reçois un email ne correspondant pas à ma situation (manuels)

Le message de confirmation de connexion subordonne l'inscription à la restitution des manuels scolaires prêtés et au fait d'être en règle avec la caisse du collège. Ce message convient aux réinscriptions, pas aux 6èmes. Solution proposée = rajouter "(pour les élèves déja inscrits au collège l'an passé)"

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/649)

---
## Lundi 17 juin

- **Rendre visible le statut d'un dossier dans l'export excel**

rendre visible le satut d'un dossier dans l'export excel. Il y a maintenant une colonne statut.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/648)

- **Informer l'agent après import comment la carte des formations a été construite**

Dans le message de fin d'import élève, préciser que la carte des formations à été déduite du fichier mais qu'il serait préférable d'aller vérifier.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/593)

---
## Vendredi 14 juin

- **En tant qu'agent, je peux créer un compte quand mon collège s'est inscrit sans créer d'agent**

Principalement pour pallier à notre problème d'email qui n'arrive pas, nous allons proposer aux agents qui veulent refaire une inscription en cours de re-envoyer un message de confiruation, avec le lien permettant de finir la procédure.

Ça ne ressoud pas le problème directement, mais nous espérons que ça permettra de le contourner dans certains cas.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/646)


---
## Jeudi 13 juin

- **En tant que secrétaire, je vois par défaut le board de configuration quand aucun dossier n'a encore été importé**

Pour guider les agents qui n'ont pas encore importer les dossiers, après l'identification, si aucun dossier n'a été importé, la redirection amène sur le module configuration. Sinon, ça pointe sur la liste des élèves.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/644)


---
## Mercredi 12 juin


- **Representant vivant à l'étranger**

Certains parents vive à l'étranger. Nous avons fait en sorte que ce soit faisable dans DossierSCO : ajout d'une liste de pays (par défaut sur FRANCE), et, si c'est un autre pays que FRANCE qui est choisi, on enlève le code postale et affiche une zone de texte pour saisir la ville.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/614)

- **Export excel incomplet**

En tant qu'agent, quand je fais un export Excel, je peux maintenant retrouver les infos suivantes dans l'export :

- la famille accepte t-elle que l'enfant soit photographié pour la photo de classe ?
- est-ce que la famille souhaite envoyer par écrit au secrétariat une information médicale ?
- quelles pieces jointes ont été fournies (une croix indiquant si la pièce a été fournie) ?


[ticket](https://gitlab.com/dossiersco/dossiersco/issues/642)

---
## Mardi 11 juin

- **Configurer le reply-to des emails envoyés aux familles**

Afin de permettre aux établissement de recevoir directement les messages des familles, nous avons changer le `reply-to` par une adresse configuré dans la « configuration de la campagne ». Par défaut on y place ce.XXX@ac-YYY.fr̀ et c'est un champ email obligatoire.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/594)

- **Enregistre le tel professionnel**

Si une personne représentante légale saisi un numéro de téléphone professionnel, il est maintenant enregistré.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/633)

- **afficher un changelog dans l'application**

Pour permettre de partager notre avancement avec les personnes utilisatrices, nous avons ajouté un fichier changelog dans le répo (doc/changelog.md) ainsi qu'un lien dans le footer de l'application.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/626)


---
## Lundi 10 juin

- **A l'import quand pas de MEF cible, chercher une MEF générale**

Dans le cas où aucune MEF de montée n'est trouvée, nous cherchons le MEF la plus générale correspondante (5EME pour l'exemple d'une 6EME BILANGUE) et l'affecter.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/623)


- **Permettre l'import des élèves de 6èmes depuis SIECLE dans DossierSCO**

Pour permettre l'import des 6eme depuis SIECLE, nous avons ajouté une selection sur le type de fichier qui va être importé afin de pouvoir le traiter en fonction de la source.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/622)

- **Permettre au collège de déclencher le début de la campagne**

L'établissement peut maintenant configurer le début de campagne.

Tant que la date n'est pas arrivée, les familles ne peuvent pas arriver sur les pages d'inscription.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/624)


- **Préciser si l'envoi d'un message se fera par mail ou SMS**

Afin de savoir par quel chemin le message va partir à une famille, afficher les moyens de communication possible (numéro de téléphone et donc SMS, mail)

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/555)

- **Rétablir les relances par SMS**

Activité technique pour branché dossiersco sur un outil pour envoyer des SMS. L'application peut maintenant envoyer des SMS aux familles.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/577)

---

## Dimanche 9 juin

- **Orthographe à corriger dans la convocation des familles**

Correction de fautes d'orthographe et reprise de certaines formulations dans la convocation des familles.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/625)


---
## Samedi 8 juin

- **Ne plus envoyer de copie à l'agent connecté**

Nous n'envoyons plus de copie des messages envoyé aux famillles aux agents.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/621)

---
## Vendredi 7 juin

- **Lien non interprété dans la page d'accueil**

Dans la page d'accueil, il est demandé aux parents de se munir des pièces.
Si l'explication de la pièce attendue est en markdown, le markdown doit maintenant être interprété correctement, de la même manière que du HTML directement.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/613)


---

## Jeudi 6 juin

- **enchainement de MEF**

J'aimerais pouvoir vérifier mes enchainements de MEF (quel MEF va dans quel MEF) et pouvoir faire des changements si besoin. DossierSCO ne trouvant pas toujours le MEF destination qui conviens, cette écrans pourrait également informer du nombre d'élèves sans MEF (ça devrait correspondre au fait de ne pas avoir de MEF destination pour certain mef)

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/606)

- **Afficher correctement les options maintenues**

Correction d'un bug qui affichait les options comme abandonnées alors qu'elles devraient apparaitre comme maintenues.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/609)

- **Alléger les contraintes de matching ENT**

Afin d'augmenter les chances de trouver le responsable légal provenant de l'ENT, nous allons chercher uniquement avec l'email s'il y en a un, et sinon, utiliser le nom, prénom et adresse.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/608)

- **Avoir une trace des problèmes d'ENT**

Afin de savoir qu'il y a un problème, lorsqu'on ne trouve pas de responsable légal et/ou de dossier avec les informations de l'ENT, nous envoyons une alerte dans SENTRY.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/607)

- **Bug sur le lien de La modification de la Demi-pension**

Bug sur le lien de La modification de la Demi-pension, dans configuration de la campagne, ne renvoie pas vers la bonne page

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/611)

- **Afficher la liste des élèves sans MEF**

A partir de l'écran de la carte des formations, nous pouvons accéder maintenant à la liste des élèves qui n'ont pas de mef destination.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/610)

---
## Mercredi 5 juin

- **Configuration de campagne**

Pour éclaircir l'organisation, en tant qu'admin, j'aimerais pouvoir accéder à tous les éléments de configuration de notre campagne au même endroit

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/603)


- **Rendre visible dans le module agent les informations générales**

Afficher les informations administrative dans le dossier élève : 

- régime de sortie
- souhait de communiquer des informations médicales
- authorisation photo de classe
- demi-pension
- numéro caf

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/602)

- **faire un feedback sur le nombre de documents importés**

Afficher toutes les images téléversé en pièces jointes (quand il y en a plusieurs).

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/255)

- **Ne pas afficher 1 et 2 sur les représentants légaux**

Les représentants légaux n'ont pas à être placé, numéroté.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/605)

- **Accepter les liens dans le corps du texte**

En tant qu'agent d'un établissement, je souhaite ajouter un lien dans le corps du texte de l'explication pour une pièce attendue

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/559)

---
## mardi 4 juin

- **Le texte des lettres de convocation concerne la réinscription, pas l'inscription en 6ème**

Changement du texte des convocations pour faire en sorte que ce texte soit valable également pour l'inscription en 6eme.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/598)

- **rendre compréhensible la liste des élèves**

En tant qu'agent, je souhaite comprendre la signification des colonnes avec l'icone "camion" et l'icone "fourchette couteau" dans la page qui liste les élèves

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/584)

- **Afficher les régimes de sortie dans l'ordre chrono de création**

En tant que famille, j'aimerai voir afficher les différents régimes de sortie dans l'ordre chronologique de crzation (comme pour les agents)

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/582)

---
## lundi 3 juin

- **Informer la famille des implications du choix d'une option pédagogique**

Ajout d'une zone d'explication sur chaque option. Configuration à partir de la carte des formations. Affichage dans la partie famille, sur la page élève, à coté des options.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/486)


- **Rendre une option d'un MEF, non accessible aux élèves qui ne la suivaient pas l'année précédente dans la base élèves**

Nous pouvons maintenant configurer une option dans un mef pour précisier si cette option est ouverte à l'inscription ou non.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/542)


- **Le caractère obligatoire d'une option a été remplacé par le caractère abandonnable**

Nous pouvons maintenant configurer une option dans un mef pour préciser si cette option est abandonnable ou non.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/493)


---
## Vendredi 31 Mai

- **Configurer si l'établissement souhaite calculer automatiquement les tarifs de cantine**

En tant qu'admin d'établissement, je peux demander ou ne pas demander l'identifiant CAF aux familles. Cet identifiant nous servira ensuite pour demander le quotient familliale des familles via [api particulier](https://api.gouv.fr/api/api-particulier.html)

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/576)


- **Afficher le recap en fin de parcours**

À la fin de l'inscription des familles, nous reprenons des éléments du dossier.


[ticket](https://gitlab.com/dossiersco/dossiersco/issues/590)

- **Faire la distinction entre les options demandables ou abandonnables**

Afficher les options de l'élève de l'an dernier, différemment des options à choisir pour l'année à venir.


[ticket](https://gitlab.com/dossiersco/dossiersco/issues/591)


---
## 30 Mai

- **Permettre au collège de mettre à disposition des familles des pdf à imprimer, pour les besoins non traités par DossierSCO**

Pour cela, nous avons donné la possiblité de mettre des liens dans :
- la page accueil
- les explications des pièces attentudes
- le régime de sortie

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/553)

