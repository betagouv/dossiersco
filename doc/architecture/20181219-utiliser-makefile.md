# Utiliser Makefile

Status: _acceptée_

## Contexte

Pour rester le plus proche possible de l'environnement de production, nous voulons utiliser des containers. Cela permet aussi de partager des envivonnement le plus proche possible entre nous.

Les commandes `docker-compose` sont parfois un peu longue, avec beaucoup d'option, alors que nous utilisons souvent les même.

## Decision

Utiliser un fichier Makefile pour avoir un set de commande simple à utiliser. 

Cette décision est très largement inspiré de l'article [Standardizing interfaces acress projets with makefiles](https://blog.trainline.eu/13439-standardizing-interfaces-across-projects-with-makefiles) lu sur le blog de Trainline.eu (ex-CapitainTrain).
