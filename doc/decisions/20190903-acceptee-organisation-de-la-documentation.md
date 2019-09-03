# Organisation de la documentation

## Contexte

La documentation est éparpillée : répertoire doc de l'appli, blog/jekyll, keybase, fiche support sur gitlab.

Nous avons du mal à extraire des synthèses des données que nous avons recueillies.

La découvrabilité de nos documents n'est pas optimale (uniquement sur github.com)

## Decision

Nous allons publier la plupart de nos documents (ceux qui ne contiennent aucune donnée à caractère personnel).

Nous allons utiliser le moteur de blog déjà en place (jekyll).

Nous allons placer ce moteur de blog sur github, pour le rapprocher de l'application et le rendre plus visible et associé à la communauté beta.gouv.fr.

Nous privilégions d'avoir l'application d'un coté, et un moteur de publication de l'autre. En séparant les deux, nous évitons l'empilement de difficulté, et donnons plus de clarté.

**Si nous voulons faire aussi bien que send.firefox.com, nous devons avoir des applications qui ne font qu'une et une seule chose** -- [https://fr.wikipedia.org/wiki/Philosophie_d%27Unix]

