# Comment contribuer

Nous sommes très heureux que vous soyez en train de lire ceci, parce que nous avons toujours besoin d'aide pour faire en sorte que ce projet soit le mieux possible.

Voici quelques ressources importantes :

  * Le mail de l'équipe qui, pour le moment, est le moyen le plus simple de nous contacter : [equipe@dossiersco.fr](mailto:equipe@dossiersco.fr)
  * [Le journal](doc/journal.md) où nous consignons quelques infos chaque fin d'itération,
  * Les [bugs et tickets](https://github.com/betagouv/dossiersco/issues) github que nous utilisons pour enregistrer toutes les demandes, les retours, les choses à faire.
  * le [board projet](https://github.com/betagouv/dossiersco/projects/1?fullscreen=true) qui pilote la vie du projet
 
## Test

Nous essayons d'écrire des tests automatisé avant d'écrire du code, mais parfois, il reste du code sans test. Si vous voulez participer, merci d'essayer de fournir un test en compagnie de votre code. ÉCrit avant ou après, ce n'est pas très grave.

Nous utilisons la librairie de test fourni par rails, basique, cela nous semble suffisant pour l'instant.


## Soumettre un changement

Veuillez envoyer une [Pull Request](https://github.com/betagouv/dossiersco/pull/new/master) avec une liste claire de ce que vous avez fait (pour en savoir plus sur les [pull requests](http://help.github.com/pull-requests/)). Assurez-vous que toutes vos livraisons sont atomiques (une fonction par livraison), ça facilite la lecture pour tout le monde.

Rédigez toujours un message clair pour vos propositions. Les messages d'une ligne sont parfaits pour les petits changements, mais les changements plus importants devraient ressembler à ceci :

    git commit -m "Verbalise un changement 
    > 
    > Utiliser un verbe en premier dans le résumé est très apprécié. Il est fortement recommandé, pour certaines modification un peu lourde ou complexe, d'ajouter un ou plusieurs paragraphe dans le message de commit. N'hésitez pas à y poser des liens si vous voulez partager des référeces.


## Conventions de code

Le code est principalement lu par des humains. Nous essayons de faciliter cela dans le code existant. Merci d'essayer de faire comme nous :)

  * Nous indentons en utilisant deux espaces (soft tabulations)
  * Nous utilisons `.html.erb` pour les extensions des fichiers de vue
  * Nous évitons la logique dans les vues, en mettant des générateurs HTML dans les `helper`
  * Nous mettons TOUJOURS des espaces après les éléments de liste et les paramètres de méthode (`[1, 2, 3]`, pas `[1,2,3]`), autour des opérateurs (`x += 1`, pas `x+=1`), et autour des flèches de hash.


Merci. Merci,
L'équipe DossierSCO


(basé sur https://github.com/opengovernment/opengovernment/blob/master/CONTRIBUTING.md)


