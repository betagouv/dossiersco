# Organiser la documentation

## Contexte

Nous accumulons beaucoup de documents, d'interview utilisateur, de
questionnement, d'information sous forme textuelle.

Ces documents sont éparpillé sur le gitlab, le keybase, le blog, le repertoire
doc de l'application (sur github).

Il n'est pas facile de faire des synthèses à partir de toutes ces informations.

Nous n'arrivons pas à justifier nos intuitions, et prenons des décisions sans
avoir vérifier qu'elles sont bien justifiées.

## Decision

Nous allons rassembler la documentation publiable (ou annonymisé) dans un
repertoire à coté du code source (le répertoire [doc](doc)).

Nous allons organiser ce répertoire doc en 4 sous répertoire :

- decisions : rassemble les fichiers documentant les prises de décisions
- hypotheses : regroupe les données nous permettant d'analyser et de prendre
  des décisions
- documents : rassemble tous les documents pouvant nous être utile pour le
  fonctionnement de DossierSCO
- procedures : regroupe des tutoriels à destination des personnes utilisant
  DossierSCO, pour les aider à réaliser un acte (retour vers siecle,
  configuration d'une campagne d'inscription, ...)

Tous ces documents sont déjà accessible librement dans le repo github de
l'équipe [https://github.com/betagouv/dossiersco]. Nous allons le publier
également sur l'application.
