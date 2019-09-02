# Connexion ENT

Dans le cadre du déploiement de DossierSCO sur l'académie de Paris, nous devons brancher DossierSCO sur l'ENT [ParisClasseNumérique](https://www.parisclassenumerique.fr/).

L'outil est distribué sous une licence libre par [Open Digital Education](https://opendigitaleducation.com/);
le code source est disponible sur [github.com/opendigitaleducation/entcore](https://github.com/opendigitaleducation/entcore)

2 modes d'authentification : OAuth et CAS. Le serveur CAS de l'ENT est plus abouti, c'est donc la piste privilégiée.

Nous avec un usage très simple de cas, pas besoin d'utiliser une gem.


Ce qu'il reste à faire :
- on peut ajouter des paramètres lors du premier appel, ils seront retransmis dans les suivants (utilisation classique d'un token pour vérifier l'identité)
- ajouter une icone avec url pour ajouter dans l'ENT
