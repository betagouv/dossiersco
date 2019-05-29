# Gérer les erreurs avec les exceptions

Status: proposée

## Contexte

Avec rails, il est facile de se perdre dans la gestion des erreurs. ActiveRecord propose un compotement basé sur un boolean (`monobjet.save` renvoie vrai ou faux), puis sur un objet tableau amélioré pour stocker les erreurs.

C'est bien pratique dans les case proposés, mais pour d'aute situation, ça ne s'adapte pas. Comment gérer les erreurs ailleurs ?

Dans notre code, il y a du coup un peu de tout. Le code n'est pas consistant.

## Decision

Utiliser systématiquement les exceptions pour gérer les cas d'erreurs.

Pour activerecord, ça signifierais utiliser les méthodes `monobjet.save!`. Nous aurons sans doute à créer des exceptions propre à dossiersco, mais j'envisage que ça améliorera la lisibilité.
