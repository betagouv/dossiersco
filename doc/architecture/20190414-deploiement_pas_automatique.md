# Déploiement pas automatique

Status: accepté

## Contexte

Après avoir reconstruit l'environnement de démo depuis zéro, nous ne pouvons
plus déployer en automatique depuis CircleCI. Puisque le CircleCI utilise la
clef SSH publique de Christophe, il faut qu'il accède à l'application.

Ça crée une relation très (trop ?) forte entre la plateforme de déploiement et
un membre de l'équipe.

## Decision

Nous pourrions avoir un script qui permet de déployer facilement à partir de la
branche courante. N'importe quel membre de l'équipe, ayant accès à la
plateforme (pour le moment Scalingo) pourrait déployer.

Le script est dans `bin/deploy`

## Conséquences

Nous recommançons à avoir une branch de demo par défaut
Nous n'aurions plus besoin de CircleCI (à condition que le script inclu
l'execution des tests)

