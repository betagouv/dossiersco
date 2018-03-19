# Passage de Redis à une base SQL

Jeudi 15 Mars un problème de duplication de champs des objets stockés
(deux "lv2" avec des valeurs différentes "Allemand" et "Espagnol")
est diagnotiqué le lendemain en mob programming comme un ennième problème
de la dialectique Ruby entre chaines et symboles.

Systématiquement utiliser des chaines de caractères dans le code est
vu comme insuffisant par @Morendil : les symboles vont revenir par la
fenêtre un jour ou l'autre.

Après un carrottage, le choix est fait de passer à une base SQL avant que
davantage de code dépendant de Redis ne soit écrit.
