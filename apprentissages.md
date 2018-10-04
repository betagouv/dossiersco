# Apprentissages

* Sauvegarder le xls depuis libreoffice est nécessaire pour l'importer dans dossiersco
* Checklist de démarrage: est-on dans un état stable - no WIP, barre verte
* Commit/push le plus fréquemment et "atomiquement" possible
* Éviter les require "de confort" - ne requirer que le strict nécessaire
* Bien lire les messages d'erreur
* Utiliser Nokogiri pour rendre plus parlants les échecs d'assertions
* Utiliser le multi-stage build de docker (pour en bénéficier, utiliser docker 1.17.05, intaller docker-ce, la version community à partir de <https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository>)
* Active_Support embarque des règles anglaises de pluralisation/singularisation et ça peut mettre la zone
* Le monkey patching est une technique avancée mais bien utile
* La gemme gemedit permet de faire `gem edit <une_gemme>`, à condition d'avoir installé vim/vi et c'est pratique
* Dans les conteneurs on est tous nus, on n'a pas les outils habituels (vim, wget, etc.) - on peut y rentrer et faire apt-get update puis `apt-get install <outil>`
* Avec docker-compose exec on peut retrouver le conteneur déjà créé donc retrouver les outils qu'on y a installés
* Les entiers en Postgres nécessitent d'être entourés de guillemets simples
* Faire du streaming pour afficher une image

## Pour créer un formulaire d'upload

* Ajouter `multiple` dans les `<input>`
* Ajouter `enctype="multipart/form-data"` dans `<form>`

## Chercher dans la doc

<https://devdocs.io/ruby/>

## Automate de réinjection dans siècle

Début mer 12 sep 17h10, fin samedi 15.

## Import privé de SIECLE

Dans la balise CODE_PARENTE, il faut mettre deux caractères. Des erreurs apparaîssent alors enfin :

* La division indiquée n'est pas rattachée au MEF de l'élève. La scolarité active de l'élève a été rejetée. ACDIV_B_01
* La date de début de scolarité "01/09/2016" n'est pas incluse dans la période scolaire (du 03/09/2018 au 01/09/2019). La scolarité active, les motif et date de sortie n'ont pas été pris en compte. SCOAC_E_02
* Le code mef "%" pour l'année précédente n'est pas référencé dans la base de données par l'établissement de connexion. Le mef pour l'année précédente a donc été forcé à null. MEFAD_C_02
