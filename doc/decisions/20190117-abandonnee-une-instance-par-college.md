# Deployer une instance par collège

## Contexte

Dans beaucoup de table, nous conservons l'identifiant établissement. Dans chaque requête, nous faisons un filtre avec ce code établissement.

## Decision

Déployer une instance par collège permettrais de ne pas avoir à stocker l'identifiant établissement et faire des filtres dessus.

Après discussion avec Scalingo, et entre nous, nous avons décidé que le coup n'en vaut pas la chandelle. Le nombre d'instance serait trop grand, alors que le problème n'est pas vraiment grave ou génant. On décide d'abandonner (pour le moment du moins)

