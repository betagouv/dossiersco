# DossierSCO

Inscrire ses enfants au collège sans se déplacer, sans redonner d'informations déjà connues et sans flux papier.

[dossiersco.fr](https://dossiersco.fr/)

## Vie de l'équipe


L'équipe fonctionne beaucoup en mode distribué sur le territoire. Cette
mobilité est une force pour nous. Pour que cela fonctionne bien, nous avons
quelques rituels. Notre rythme principal c'est la semaine.

### Quotidienne

  Points quotidiens à 10h;
  en fonction des personnes présentes;
  pour organiser la journée;
  sur un outil de visio-conférence ([zoom](https://zoom.us/) bien souvent).

L'objectif est de permettre à l'équipe de s'auto-organiser, en gardant le focus
sur l'objectif court terme. C'est aussi un moment où chaque personne de
l'équipe peut demander de l'aide sur un sujet particulier.

La quotitienne doit durer autour de 10 minutes. Elle peut donner lieu à des
rendez-vous ultérieur dans la journée pour traiter plus en profondeur d'un
sujet particulier.

En fin de quotidienne, l'équipe présente relai les points de rendez-vous et les
autres messages important sur le slack de l'équipe, pour permettre aux
personnes absentes de rester informer.


### Journal

  Chaque fin de journée;
  chaque personne ayant travaillée sur le projet dans la journée;
  devra avoir écrit un petit bout de texte pour parler de ce qu'elle a fait.

Afin de faciliter la synchronisation de toutes les personnes participantes, et
pour éviter les longues réunions, ce fichier sera constituer comme chacune le
préfère. Pour certaine personne, au fil de l'eau, pour d'autre en fin de
journée.

Pour simplifier, il y aura un [éditeur pour le journal du
jour](https://hackmd.io/KHIgMl23RGufrygMtw3A_w#) sur invitation, pour les
membres de l'équipe. Ce journal comporte une partie privée qui restera dans les
archives de l'équipe, et une partie publique qui sera publié sur le blog.


### Rétrospective

  En fin d'itération;
  prendre du temps pour l'équipe;
  prendre du recul;
  pour observer la façon de travailler de l'équipe;
  et ensemble progresser.


Selon les situations, nous pourrons utiliser divers format.

En essayant de garder un temps relativement court (1h, 1h30 max). Les journaux
privée et publique de la semaine pourront nous aider à repenser notre semaine.

Des actions d'amélioration, qui n'auraient pas été dédecté ou décidé en cours
d'itération pourront être mises en place.


### Artefacts:

Ces rituels génère des documents vie à vie du projet et de l'équipe :

- [Journal de l'équipe](https://gitlab.com/dossiersco/dossiersco/blob/master/doc/journal.md)
- Le [blog de l'équipe](https://blog.dossiersco.fr/)


## Documentation

- [L'histoire des décisions d'architecture](https://gitlab.com/dossiersco/dossiersco/tree/master/doc/architecture)
- le [suivi des travaux sur le projet](https://gitlab.com/dossiersco/dossiersco/boards)

## Développement

Le code source est disponible sur [gitlab.com/dossiersco](https://gitlab.com/dossiersco).

Pour faciliter la mise en place d'environnement, nous nous basons sur
[docker](https://www.docker.com/). Les commandes principales sont placées dans
un [`Makefile`](https://www.gnu.org/software/make/manual/make.html). Il est
possible que certaines commandes particulières nécessitent malgré tout
d'explorer les commandes ̀ docker` et plus particulièrement `docker-compose`.


Pour cloner le repository :

```bash git clone https://gitlab.com/dossiersco/dossiersco.git ```


Pour constuire le projet (installer les gems entre autres) : 

```bash make build ```


Pour démarrer les serveurs (base de données et application) : 

```bash make run ```


L'accès à l'application se fait ensuite par <http://0.0.0.0:9393/>.


Pour lancer les tests :

```bash make test ```


Pour lancer un test en particulier :

```bash docker-compose run --rm test rails test <mon fichier ex: test/models/agent_test.rb> ```


Pour accéder à la console rails :

```bash make console ```

Pour peupler l'application en local :

```bash rake db:vide db:seed:demo```


## Outils

- Tous les identifiants et mots de passe sont stockés dans
  [Keybase](https://keybase.io/)
- Les mails transactionnels sont envoyés via [Mailjet](https://mailjet.com)
- On attrape toutes les erreurs sur
  [Sentry](https://sentry.io/betagouv-pe/rails/)
- Sur les environnements de développement et staging les emails sortants sont
  envoyés avec [Letter Opener Web](https://github.com/ryanb/letter_opener). On
  peut les consulter à l'url `/letter_opener`
- Envoie de SMS avec [NEXMO](https://www.nexmo.com/)
- Nous analysons les connexions avec [Matomo](https://matomo.org/). Pour
  accéder à l'interface du projet [dossierSco sur le compte de
  beta.gouv.fr](https://stats.data.gouv.fr/index.php?module=CoreHome&action=index&idSite=54&period=range&date=previous30&updated=1#?idSite=54&period=range&date=previous30&category=Dashboard_Dashboard&subcategory=1).
  Voir [beta.bouv.fr/suivi/](https://beta.gouv.fr/suivi/)
- Support utilisateurs en direct à l'aide de [Drift](https://app.drift.com/)
