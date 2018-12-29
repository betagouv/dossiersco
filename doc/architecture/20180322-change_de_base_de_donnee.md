# Changer de base de donnée

Status: acceptée

## Contexte

_
### Le problème de la dualité chaines/symboles

Jeudi 15 Mars un problème de duplication de champs des objets stockés
(deux "lv2" avec des valeurs différentes "Allemand" et "Espagnol")
est diagnotiqué le lendemain en mob programming comme un ennième problème
de la dialectique Ruby entre chaines et symboles.

Systématiquement utiliser des chaines de caractères dans le code est
vu comme insuffisant par @Morendil : les symboles vont revenir par la
fenêtre un jour ou l'autre.

Après un carrottage, le choix est fait de passer à une base SQL avant que
davantage de code dépendant de Redis ne soit écrit.

### Les temps de réponse sont dégradés par le passage à PostgreSQL

Une augmentation des temps de réponse de près de 50 % est constatée :

* redis : accueil servi en ~ 770 ms
* postgres : accueil servi en ~ 1100 ms

Ces temps de réponse sont dus à l'emploi du server shotgun pour relancer
à chaque requête le serveur.

En passant au serveur builtin de sinatra (rackup) on descent vers 30 ms.
Changements à faire :

* "bundle exec rackup -p9393 --host 0.0.0.0" dans docker-compose.yml
* require 'rack' dans dossiersco_web.rb


## Decision

La configuration de postgres dans docker-compose.yml est plus légère que
celle de mysql. Les plans financiers sur les services d'hébergement en
europe sont raisonnables pour postgres :

* scalingo : gratuit jusqu'à 500 Go, 14 Euros pour 1 Go / 60 connexions simultanées
* heroku : gratuit jusqu'à 10000 lignes, 9$ pour 10 Millions de lignes /
 20 connexions simultanées, 50$ pour 64 Go / 120 connexions


