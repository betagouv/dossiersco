# Journal


## Semaine du 1er au 7 février

*Nous sommes heureux d'avoir ouvert la porte, nous attendons les établissements*

### Vie de l'équipe

- On pourrait essayer de faire un autre format, attention à prévoir le temps de le faire.
- Plutôt que d'utiliser mattermost, on va tenter Drift pour le support utilisateur.
- Faire avancer la checklist de la bonne communauté  https://github.com/betagouv/dossiersco/community en commançant par un template issue.
- Expliciter le regard du coach cette semaine
- Changement de posture pour une attention plus forte sur l'opérationnel, pour les échanges politiques, nous allons nous appuyer sur nos alliées.
- On commence à prendre l'habitude d'écrire un post-it pour organiser les digressions.
- Pierre utilise le git de keybase pour les notes discrètes
- On continue à tourner toutes les 25 minutes au clavier, ça apporte du rythme.
- La priorisation du backlog, pour choisir le travail de la semaine, était tourné uniquement vers les bug
- Nous avons commencé une carte d'histoire des utilisateurs et utilisatrices du dernier conseil de classe à la constitution des emplois du temps de rentrée. C'est un travail qui nous aidera à : 
    - prioriser le backlog
    - faire une roadmap
    - faire des annonces
- On fait un peu plus équipe avec le lab 110bis, et c'est vraiment chouette.
- Nous sommes alignés sur le fait de monter rapidement un kickoff
- Nous sommes en production, d'ailleurs on a décidé de n'avoir qu'un environnement de production (la démo est supprimée) https://dossiersco.beta.gouv.fr.

> Le temps n'est pas une variable d'ajustement


### Code



### Intraprenariat

- Pierre et Christophe rendent visite au collège Oeben de Paris
- Pierre a noué des contacts très intéressant avec des académies grace au dispositif mis en place par le lab 110Bis lors de la réunion mensuelle des recteurs.

> Le service en ligne d'inscription des collégiens qui transforme une campagne de masse en accueil individualisé des familles.


---


## Semaine du 25 au 31 janvier

*On maintient la porte entre-fermée aux personnes utilisatrices, et on a hâte de l'ouvrir*

### Vie de l'équipe

- Comment faire la rétrospective a distance ?
- On pourrait essayer de faire un autre format, attention à prévoir le temps de le faire.
- Manque de confiance dans la robustesse de l'application : ralentissement dans la distribution des accès
- Impression d'être dans le rush
- On a re-écrit du code pour s'adapter à rails, et du coup enlevé des tests qui ne fonctionnaient plus, au lieu de les réécrire.
- Crainte de voir les utilisateurs de l'an dernier découvrir des régressions parce qu'on a pas encore stabilisé suite à la migration
- On livre sans forcement tester dans le contexte de production (démo compris)
- On ajoute des définitions de fini (sous forme de note en haut de la colonne done)
- On a amorcé des discussions sur la bien-traitance des personnes utilisant dossiersco
- Sentry ne se branche pas sur Slack, à cause du Slack : on pourrait ouvrir un mattermost pour faire les branchements dessus et pourquoi pas faire le support et la formation dessus.
- On a (enfin) commencé à tourner régulièrement au clavier, juste le dernier du coup, pas grand chose à en apprendre (pour le moment)
- Les désaccords surgissent, et on arrive très bien s'en servir pour progresser
- Est-ce que ça ne serais pas intéressant d'utiliser le wiki github pour le journal et d'autres éléments ?
- Quand on est à Arago, on va aller manger à la cantine (même avec nos plats de dehors)


### Code

- [Supprimer Etablissement : échec sur lycée ARAGO bis](https://github.com/betagouv/dossiersco/issues/277)
- [Upload de document via smartphone](https://github.com/betagouv/dossiersco/issues/225)
- [impossible de prendre une photo avec son tel pour ajouter une pièce jointe](https://github.com/betagouv/dossiersco/issues/272)
- [Sign in du super admin ne fonctionne plus](https://github.com/betagouv/dossiersco/issues/278)
- [Afficher qui est l'agent connecté](https://github.com/betagouv/dossiersco/issues/274)
- [Afficher l'établissement en cours dans les interfaces agents](https://github.com/betagouv/dossiersco/issues/273)
- [Un agent peut visualiser les pièces jointes à un dossier](https://github.com/betagouv/dossiersco/issues/227)
- [créer et mettre à jour les MEF automatiquement à partir du fichier siecle](https://github.com/betagouv/dossiersco/issues/221)
- [Lister, voir, créer, modifier et supprimer des etablissements](https://github.com/betagouv/dossiersco/issues/263)
- [afficher les options pédagogiques coté famille](https://github.com/betagouv/dossiersco/issues/219)
- [Préview des document PDF](https://github.com/betagouv/dossiersco/issues/226)
- [upload des pièces jointes avec le framework](https://github.com/betagouv/dossiersco/issues/234)
- [créer la notion de super admin et limiter le switch établissement](https://github.com/betagouv/dossiersco/issues/260)
- [Ajouter une contrainte sur la création de compte agent](https://github.com/betagouv/dossiersco/issues/264)
- [Faire pointer l'url dossiersco.beta.gouv.fr sur dossiersco.scalingo.io](https://github.com/betagouv/dossiersco/issues/251)
- [Lister, voir, supprimer, modifier des agents](https://github.com/betagouv/dossiersco/issues/261)
- [ajouter le formulaire de création d'établissement dans le menu configuration](https://github.com/betagouv/dossiersco/issues/223)
- [Migrer les données de production](https://github.com/betagouv/dossiersco/issues/211)
- [Lister les contacts du ministère et leur place dans l'organigramme](https://github.com/betagouv/dossiersco/issues/266)
- [Le champ Date limite dans interface agent / établissement ne mémorise pas les infos saisies](https://github.com/betagouv/dossiersco/issues/275)

### Intraprenariat

- Stéphane passe l'après midi avec le collège la Garriguette de Vergeze (34)
- Nous élargissons les contacts avec des partenaires potentiels
- Appeler Sonia DELAUNAY (60)
- Appeler Du Pevele
- Appeler Evariste Galois
- Appeler Le Bocage
- [Contacter le premier grand expert du comité](https://github.com/betagouv/dossiersco/issues/253)
- [Contacter Mairie de Paris](https://github.com/betagouv/dossiersco/issues/254)


---

## Semaine du 21 au 25 janvier

*Les utilisateurs et utilisatrices arrivent*

### Vie de l'équipe

- soulagement de commencer à avoir les établissements au téléphone
- nous avons su évoquer les inquiétudes des uns et des autres et agir en conséquence pour avancer
- nous vérifions que le rythme court nous permet de résoudre rapidement nos difficultés
- difficile de trouver le bon moment pour travailler à 4 derrière l'écran
- nous partageons maintenant le même backlog (code et intraprenariat) pour prioriser nos actions quotidiennement


### Incréments code

- [Mettre en place l'internationalisation de l'interface utilisateur des familles](https://github.com/betagouv/dossiersco/issues/213)
- [Supprimer les anciens comptes agents](https://github.com/betagouv/dossiersco/issues/259)
- [Ajouter le formulaire de création des agents dans le menu configuration](https://github.com/betagouv/dossiersco/issues/222)
- [Restreindre la configuration aux admin](https://github.com/betagouv/dossiersco/issues/224)
- [Faire pointer l'url demo.dossiersco.beta.gouv.fr sur dossiersco-demo.scalingo.io](https://github.com/betagouv/dossiersco/issues/252)
- [Paramétrer les options pédagogiques par mef](https://github.com/betagouv/dossiersco/issues/215)
- [Ne pas envoyer d'email par défaut](https://github.com/betagouv/dossiersco/issues/209)
- [Trouver un collège ayant une 6e non francophone](https://github.com/betagouv/dossiersco/issues/200)
- [Migrer sur Scalingo](https://github.com/betagouv/dossiersco/issues/191)


### Incréments humain

- appel avec l'établissement Jean Texcier (76)
- appel avec l'établissement Boris Vian (14)
- appel avec l'établissement La Gariguette (34)
- appel avec l'établissement Malraux (45)
- appel avec l'établissement Germinal (62)
- reconfiguration du conseil des sages
- intérêt manifesté de la mairie de Paris
- Pierre fait 4 pitch dans la semaine : Open 110Bis lab, ministre de l'Éducation Nationale Colombienne, standup BetaGouv et Alpha.

---


## Semaine du 14 au 18 janvier

*On fait équipe avec des outils communs et les 6e pointent le bout de leur nez*

### Vie de l'équipe

- Nous faisons vraiment équipe :
  - nous utilisons tous les mêmes outils (github pour le code et le public, keybase pour le privée et les brouillons/recherche):
  - nous travaillons tous sur le backlog
  - nous mettons au point ensemble la stratégie
- Le lab 110Bis prends bien soin de nous (espace reservé malgré un évènement, ...)
- Ajout d'un deuxième projet dans github pour faire le suivi de l'acquisition/activation des établissements [Participation Établissement](https://github.com/betagouv/dossiersco/projects/2).


### Points d'améliorations

- prévoir 60 minutes à la fin de la dernière session pour remplir le journal hebdo
- améliorer le suivi des prospects


### Incréments code

- [Affiche correctement les changements d'adresse](https://github.com/betagouv/dossiersco/issues/206)
- [L'import de SIECLE dans DossierSCO semble cassé](https://github.com/betagouv/dossiersco/issues/205)
- [Revoir le style des pages 404 et 500](https://github.com/betagouv/dossiersco/issues/193)
- [Déployer une instance par collège](https://github.com/betagouv/dossiersco/issues/181)
- [Utiliser LetterOpener sur staging](https://github.com/betagouv/dossiersco/issues/196)
- [Accès à l'outil tier d'envoi d'email](https://github.com/betagouv/dossiersco/issues/187)
- [Reprendre la configuration de l'outil tier d'envoie de mail](https://github.com/betagouv/dossiersco/issues/190)
- [mauvaise sauvegarde des options](https://github.com/betagouv/dossiersco/issues/192)


### Incréments service

- amorcer une documentation nos évènements futur : kickoff, conseil des sages, openlab, et bizdev.
- discuter budget/dépenses et remonter d'informations aux sponsors.
- reçu deux fichiers affelnet et déterrer un troisième.
- contact avec la DSI de Paris à propos d'affelnet.
- ajouter tickets au backlog


---

## Semaine du 7 au 11 janvier

*La saison 2 démarre sur les rails (migration de sinatra vers rails)*

### Vie de l'équipe

- 4 jours non stop de [mobProgramming](https://mobprogramming.org/), et c'était particulièrement bien.
- [agenda public](https://calendar.google.com/calendar/embed?src=contact%40dossiersco.beta.gouv.fr&ctz=Europe%2FParis)
- ouverture et fermeture quotidienne

Points d'améliorations :

- utiliser le jeudi fin d'après midi pour faire demo-retro-planning (ce journal a l'air d'un outil pour ça)
- prévoir 30 minutes à la fin de la dernière session pour remplir le journal hebdo
- mettre un lien dans l'application vers le journal

### Incréments

code :

- [Mise en place d'ADR (Architecture decision record)](https://github.com/betagouv/dossiersco/issues/179)
- [Migration de Sinatra vers Rails](https://github.com/betagouv/dossiersco/issues/178)
- [Remise en fonction de la surveillance d'erreur](https://github.com/betagouv/dossiersco/issues/189)
- [documentation de l'accès à l'outil de surveillance des erreurs](https://github.com/betagouv/dossiersco/issues/186)
- [Affichage correct des contacts de l'élève](https://github.com/betagouv/dossiersco/issues/194)


humain :

- visibilité sur le protocole de tests à effectuer pour les 20 premiers collèges
- premier brouillon de mail pour l'embarquement de la communauté
