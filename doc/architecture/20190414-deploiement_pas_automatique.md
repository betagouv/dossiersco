# Déploiement pas automatique

Status: rejeté

## Contexte

Après avoir reconstruit l'environnement de démo depuis zéro, nous ne pouvons
plus déployer en automatique depuis CircleCI. Puisque le CircleCI utilise la
clef SSH publique de Christophe, il faut qu'il accède à l'application.

Ça crée une relation très (trop ?) forte entre la plateforme de déploiement et
un membre de l'équipe.

## Decision

Après avoir envisager de revenir à un script qui permet de déployer facilement à partir de la
branche courante, nous avons finalement opté pour garder un déploiement automatique.

Par contre, pour résoudre le soucis du déploiement à partir de CircleCI avec la
clef publique d'un membre de l'équipe, nous allons branché directement Scalingo
à notre github.

Nous allons également déployer automatiquement en production et en démo à
partir d'une seule branche, renomé Master; Gestion en
[trunk-based](https://en.wikipedia.org/wiki/Trunk_%28software%29).
