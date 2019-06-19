## mercredi 19 juin

### Indique comment envoyer un fichier d'import en erreur

Un fichier en erreur peut être déposé sur https://send.firefox.com et le lien ainsi généré envoyé à l'équipe.

## lundi 17 juin

### Rendre visible le statut d'un dossier dans l'export excel

rendre visible le satut d'un dossier dans l'export excel. Il y a maintenant une colonne statut.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/648)

## vendredi 14 juin

### En tant qu'agent, je peux créer un compte quand mon collège s'est inscrit sans créer d'agent

Principalement pour pallier à notre problème d'email qui n'arrive pas, nous allons proposer aux agents qui veulent refaire une inscription en cours de re-envoyer un message de confiruation, avec le lien permettant de finir la procédure.

Ça ne ressoud pas le problème directement, mais nous espérons que ça permettra de le contourner dans certains cas.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/646)


## jeudi 13 juin

### En tant que secrétaire, je vois par défaut le board de configuration quand aucun dossier n'a encore été importé

Pour guider les agents qui n'ont pas encore importer les dossiers, après l'identification, si aucun dossier n'a été importé, la redirection amène sur le module configuration. Sinon, ça pointe sur la liste des élèves.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/644)


## mercredi 12 juin


### Representant vivant à l'étranger

Certains parents vive à l'étranger. Nous avons fait en sorte que ce soit faisable dans DossierSCO : ajout d'une liste de pays (par défaut sur FRANCE), et, si c'est un autre pays que FRANCE qui est choisi, on enlève le code postale et affiche une zone de texte pour saisir la ville.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/614)

### Export excel incomplet

En tant qu'agent, quand je fais un export Excel, je peux maintenant retrouver les infos suivantes dans l'export :

- la famille accepte t-elle que l'enfant soit photographié pour la photo de classe ?
- est-ce que la famille souhaite envoyer par écrit au secrétariat une information médicale ?
- quelles pieces jointes ont été fournies (une croix indiquant si la pièce a été fournie) ?


[ticket](https://gitlab.com/dossiersco/dossiersco/issues/642)

## Mardi 11 juin

### Configurer le reply-to des emails envoyés aux familles

Afin de permettre aux établissement de recevoir directement les messages des familles, nous avons changer le `reply-to` par une adresse configuré dans la « configuration de la campagne ». Par défaut on y place ce.XXX@ac-YYY.fr̀ et c'est un champ email obligatoire.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/594)

### Enregistre le tel professionnel

Si une personne représentante légale saisi un numéro de téléphone professionnel, il est maintenant enregistré.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/633)

### afficher un changelog dans l'application

Pour permettre de partager notre avancement avec les personnes utilisatrices, nous avons ajouté un fichier changelog dans le répo (doc/changelog.md) ainsi qu'un lien dans le footer de l'application.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/626)


## lundi 10 juin

### A l'import quand pas de MEF cible, chercher une MEF générale

Dans le cas où aucune MEF de montée n'est trouvée, nous cherchons le MEF la plus générale correspondante (5EME pour l'exemple d'une 6EME BILANGUE) et l'affecter.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/623)


### Permettre l'import des élèves de 6èmes depuis SIECLE dans DossierSCO

Pour permettre l'import des 6eme depuis SIECLE, nous avons ajouté une selection sur le type de fichier qui va être importé afin de pouvoir le traiter en fonction de la source.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/622)

### Permettre au collège de déclencher le début de la campagne

L'établissement peut maintenant configurer le début de campagne.

Tant que la date n'est pas arrivée, les familles ne peuvent pas arriver sur les pages d'inscription.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/624)

### Préciser si l'envoi d'un message se fera par mail ou SMS

Afin de savoir par quel chemin le message va partir à une famille, afficher les moyens de communication possible (numéro de téléphone et donc SMS, mail)

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/555)

## samedi 8 juin

### Ne plus envoyer de copie à l'agent connecté

Nous n'envoyons plus de copie des messages envoyé aux famillles aux agents.


## mardi 4 juin

### Le texte des lettres de convocation concerne la réinscription, pas l'inscription en 6ème

Changement du texte des convocations pour faire en sorte que ce texte soit valable également pour l'inscription en 6eme.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/598)



## lundi 3 juin

### Informer la famille des implications du choix d'une option pédagogique

Ajout d'une zone d'explication sur chaque option. Configuration à partir de la carte des formations. Affichage dans la partie famille, sur la page élève, à coté des options.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/486)


### Rendre une option d'un MEF, non accessible aux élèves qui ne la suivaient pas l'année précédente dans la base élèves

Nous pouvons maintenant configurer une option dans un mef pour précisier si cette option est ouverte à l'inscription ou non.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/542)


### Le caractère obligatoire d'une option a été remplacé par le caractère abandonnable

Nous pouvons maintenant configurer une option dans un mef pour préciser si cette option est abandonnable ou non.

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/493)


## vendredi 31 Mai

### Configurer si l'établissement souhaite calculer automatiquement les tarifs de cantine

En tant qu'admin d'établissement, je peux demander ou ne pas demander l'identifiant CAF aux familles. Cet identifiant nous servira ensuite pour demander le quotient familliale des familles via [api particulier](https://api.gouv.fr/api/api-particulier.html)

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/576)


### Afficher le recap en fin de parcours

À la fin de l'inscription des familles, nous reprenons des éléments du dossier.


[ticket](https://gitlab.com/dossiersco/dossiersco/issues/590)

### Faire la distinction entre les options demandables ou abandonnables

Afficher les options de l'élève de l'an dernier, différemment des options à choisir pour l'année à venir.


[ticket](https://gitlab.com/dossiersco/dossiersco/issues/591)


## 30 Mai

### Permettre au collège de mettre à disposition des familles des pdf à imprimer, pour les besoins non traités par DossierSCO

Pour cela, nous avons donné la possiblité de mettre des liens dans :
- la page accueil
- les explications des pièces attentudes
- le régime de sortie

[ticket](https://gitlab.com/dossiersco/dossiersco/issues/553)

