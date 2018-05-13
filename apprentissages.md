# Apprentissages

*   Sauvegarder le xls depuis libreoffice est nécessaire pour l'importer dans dossiersco
*   Checklist de démarrage: est-on dans un état stable - no WIP, barre verte
*   Commit/push le plus fréquemment et "atomiquement" possible
*   Eviter les require "de confort" - ne requirer que le strict nécessaire
*   Bien lire les messages d'erreur
*   Utiliser Nokogiri pour rendre plus parlants les échecs d'assertions
*   Utiliser le multi-stage build de docker
(pour en bénéficier, utiliser docker 1.17.05, intaller docker-ce, la version
community à partir de
https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository)

* Active_Support embarque des règles anglaises de pluralisation/singularisation et ça peut mettre la zone
* Le monkey patching est une technique avancée mais bien utile
* La gemme gemedit permet de faire "gem edit <unegemme>", à condition d'avoir installé vim/vi et c'est pratique
* Dans les conteneurs on est tous nus, on n'a pas les outils habituels (vim, wget, etc.) - on peut y rentrer et faire apt-get update puis apt-get install <outil>
* Avec docker-compose exec on peut retrouver le conteneur déjà créé donc retrouver les outils qu'on y a installés
* Les entiers en Postgres nécessitent d'être entourés de guillemets simples
* Faire du streaming pour afficher une image

## Pour créer un formulaire d'upload
* ajouter "multiple" dans les <input>
* ajouter enctype="multipart/form-data" dans <form>

## Chercher dans la doc
http://devdocs.io/ruby/

