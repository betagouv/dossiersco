# Journal d'une chasse au bug

J'arrive bien à reproduire en prod... Je vais regarder là bas directement pour
l'analyse

## Mauvais endroit, mauvaise personne

**Pourquoi, après l'affichage de la page d'erreur (500), en cliquant sur le
bouton « retour à l'accueil » je me retrouve en page avec une élève déjà
connecté sur l'interface famillle ?**

Je n'arrive pas à reproduire localement... :perplexe:

Pour l'erreur, je viens de comprendre :
- en prod,
- en tant qu'admin de pilatre, je vais visualiser les pièces jointes d'un
  élève,
- j'ai une erreur avec le message de l'équipe DossierSCO,
- j'appuie sur le bouton bleu de retour à l'accueil
- je me retrouve sur la page d'accueil d'inscription d'une autre élève, d'un
  autre établissement....

Sur ce dernier point, au moment de retourner sur l'accueil, on test d'abord si
une ou un élève est connecté, et si oui, on redirige sur l'accueil de cette
famillle.

Donc en cherchant l'identifiant qui est dans la session, on trouve `nil` comme
valeur. Mais voilà, une élève à `nil` comme valeur d'identifiant...

Cette découverte n'explique pas encore pourquoi cette élève a un identifiant
`nil` ni pourquoi il y a un soucis avec les pièces jointes de l'autre,
mais ça explique pourquoi ce saut un peu surprenant depuis la page erreur.

## Identifiant NIL

**Pourquoi l'élève à un identifiant `nil` en production**

Il y a bien que une élève qui a un identifiant NIL. Elle est associé à deux
dossiers sur deux établissements, un dans le sud et un dans l'est.

Elle est de l'est pour de vrai... Comment est-elle aussi sur le sud ? Un test
de travers ?

Je ne vois pas le fichier de l'établissement en question dans nos répertoire
(cool, ils ont fait tout seul ? \o/).

**Du coup, je ne peux pas voir s'il y a un soucis à la source (dans le fichier,
est-ce que cette élève a un identifiant ?** _peut-être un coup de fil à passer
à l'établissement ?_

_Faut-il ajouter une règle : pas d'élève avec un identifiant nil._


## Pièces jointes en echec

**Pourquoi les pièces jointes du premier élève n'apparaissent pas en préview
?**

Cet élève ne pourrait plus être importé. Est-ce que c'est parce qu'il n'a pas
de mef destination que ça ne fonctionne pas ? Je ne pense pas.

Est-ce que la pièce jointe de Pierre est foireuse ? J'ai essayé sur un autre
élève, localement, avec un PDF à moi, et ça fonctionne. Je vais essayer sur
l'élève sur la base de prod.

Je confirme que ça viens de la pièce jointe de Pierre. Qu'est-ce qui ne
fonctionne pas bien dans ce PDF. Est-ce un problème au moment de l'upload
(soucis réseau local ?) ou bien le format du fichier ?

Est-ce que le fichier est quelques part sur amazon ? Est-ce que je peux le
récupérer pour voir ?  Je viens de regarder avec
[S3cmd](https://github.com/s3tools/s3cmd) et la config S3 présente sur le
keybase, mais je ne vois pas de trace du fichier. Étonnant !


