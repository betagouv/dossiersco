# Change de framework

Status: acceptée

## Contexte

Sinatra n'est pas un _framework_ mais une librairie. Sinatra est peut connu. La
mise en place de certaine chose (comme l'upload de document) semble plus
compliqué avec Sinatra qu'avec Rails.

Il commence à y avoir beaucoup de route, et les controlleurs manque.

## Decision

Basculer sur Ruby On Rails avant d'ajouter plus de code dans Sinatra.

## Conséquences

Plus de fichiers et de code, mais une organisation plus classique pour qui
connais le framework Ruby On Rails.

L'organisation des tests devrait également être un peu modifié.
