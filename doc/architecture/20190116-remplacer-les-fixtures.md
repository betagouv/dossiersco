# Remplacer les fixtures

Status: en cours

## Contexte

L'utilisation de _fixture_ ne permet pas d'avoir un environnement neutre au démarrage d'un test, éloigne des tests les informations du contexte.

La construction des données telle quelle existe aujourd'hui, n'utilise même pas les fixtures minitest, mais l'appel d'une fonction étrange.

## Decision

- Mettre en place [Fabrication](https://www.fabricationgem.org/).

- Déplacer la procédure d'initialisation de quelques données fictives dans une tache `Rake` permettant de peupler n'importe quelle base de donnée.

